#!/bin/bash
# ─────────────────────────────────────────────────────────────────────────────
# deploy.sh — one-command deploy for MysticsInventory on the production server
#
# Usage:
#   bash deploy.sh              # interactive — prompts for PM2 app name once
#   PM2_APP=mystics bash deploy.sh   # non-interactive / CI
#
# What it does (in order):
#   1. git pull (latest code)
#   2. pnpm install (sync dependencies)
#   3. Build API server  (esbuild → artifacts/api-server/dist/)
#   4. Build frontend    (vite   → artifacts/inventory/dist/public/)
#   5. Apply DB schema   (drizzle-kit push --force — safe, idempotent)
#   6. Restart PM2 app
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

# ── colour helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✔  $*${NC}"; }
info() { echo -e "${CYAN}▶  $*${NC}"; }
warn() { echo -e "${YELLOW}⚠  $*${NC}"; }
fail() { echo -e "${RED}✘  $*${NC}"; exit 1; }

# ── resolve project root (script may be run from any directory) ───────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
info "Working directory: $(pwd)"

# ── PM2 app name ──────────────────────────────────────────────────────────────
if [[ -z "${PM2_APP:-}" ]]; then
  # Try to auto-detect from running PM2 list
  if command -v pm2 &>/dev/null; then
    DETECTED=$(pm2 jlist 2>/dev/null | python3 -c "
import sys, json
try:
    apps = json.load(sys.stdin)
    names = [a['name'] for a in apps]
    print(names[0] if len(names)==1 else '')
except: pass
" 2>/dev/null || true)
  fi
  if [[ -n "${DETECTED:-}" ]]; then
    PM2_APP="$DETECTED"
    warn "Auto-detected PM2 app: $PM2_APP  (set PM2_APP=name to override)"
  else
    echo ""
    read -rp "  PM2 app name (e.g. mystics-api): " PM2_APP
    [[ -z "$PM2_APP" ]] && fail "PM2 app name is required"
  fi
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${CYAN}  Deploying MysticsInventory            ${NC}"
echo -e "${CYAN}  PM2 app : ${PM2_APP}                  ${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""

# ── 1. Pull latest code ───────────────────────────────────────────────────────
info "Step 1/6 — git pull"
git pull --ff-only || fail "git pull failed. Resolve conflicts manually."
ok "Code updated"

# ── 2. Install dependencies ───────────────────────────────────────────────────
info "Step 2/6 — pnpm install"
pnpm install --frozen-lockfile
ok "Dependencies synced"

# ── 3. Build API server ───────────────────────────────────────────────────────
info "Step 3/6 — Build API server"
pnpm --filter @workspace/api-server run build
ok "API server built → artifacts/api-server/dist/"

# ── 4. Build frontend ─────────────────────────────────────────────────────────
info "Step 4/6 — Build frontend"
pnpm --filter @workspace/inventory run build
ok "Frontend built → artifacts/inventory/dist/public/"

# ── 5. Apply DB schema changes ────────────────────────────────────────────────
info "Step 5/6 — Apply DB schema (drizzle-kit push)"
pnpm --filter @workspace/db run push-force
ok "DB schema up to date"

# ── 6. Restart PM2 ───────────────────────────────────────────────────────────
info "Step 6/6 — Restart PM2 app: $PM2_APP"
if pm2 restart "$PM2_APP"; then
  ok "PM2 app '$PM2_APP' restarted"
else
  warn "pm2 restart failed — trying pm2 reload..."
  pm2 reload "$PM2_APP" || fail "Could not restart '$PM2_APP'. Check: pm2 list"
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}  Deploy complete!                      ${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
pm2 show "$PM2_APP" 2>/dev/null | grep -E "status|uptime|restarts" || true
