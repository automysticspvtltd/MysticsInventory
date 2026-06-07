import { useState, type FormEvent } from "react";
import { Link, useLocation } from "wouter";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { customFetch, ApiError } from "@workspace/api-client-react";
import type { AuthSession } from "@workspace/api-client-react";
import { useAuth } from "@/lib/auth";
import { AuthShell } from "@/components/AuthShell";

const basePath = import.meta.env.BASE_URL.replace(/\/$/, "");

export default function SignInPage() {
  const [, setLocation] = useLocation();
  const { refresh } = useAuth();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setError(null);
    setSubmitting(true);
    try {
      await customFetch<AuthSession>("/api/auth/login", {
        method: "POST",
        body: JSON.stringify({ username, password }),
      });
      await refresh();
      setLocation("/dashboard");
    } catch (err) {
      const apiErr = err as ApiError;
      const data = apiErr?.data as { error?: string; code?: string } | undefined;
      setError(data?.error ?? "Sign-in failed");
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <AuthShell>
      <form onSubmit={onSubmit} className="w-full space-y-2" noValidate>
        {error && (
          <Alert variant="destructive" data-testid="signin-error" className="mb-3">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        <input
          id="signin-username"
          type="text"
          autoComplete="username"
          required
          placeholder="Username"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          data-testid="input-signin-email"
          className="w-full bg-[#fafafa] border border-[#dbdbdb] rounded-[3px] text-[14px] px-3 py-2.5 placeholder:text-[#8e8e8e] focus:outline-none focus:border-[#a8a8a8] transition-colors"
        />

        <input
          id="signin-password"
          type="password"
          autoComplete="current-password"
          required
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          data-testid="input-signin-password"
          className="w-full bg-[#fafafa] border border-[#dbdbdb] rounded-[3px] text-[14px] px-3 py-2.5 placeholder:text-[#8e8e8e] focus:outline-none focus:border-[#a8a8a8] transition-colors"
        />

        <button
          type="submit"
          disabled={submitting || !username || !password}
          data-testid="btn-signin-submit"
          className="w-full mt-2 bg-[hsl(38_80%_48%)] hover:bg-[hsl(38_80%_42%)] disabled:opacity-50 disabled:cursor-not-allowed text-white font-semibold text-[14px] rounded-[8px] py-2 transition-colors"
        >
          {submitting ? "Logging in…" : "Log in"}
        </button>

        <div className="flex items-center gap-3 my-3">
          <div className="flex-1 h-px bg-[#dbdbdb]" />
          <span className="text-[13px] font-semibold text-[#8e8e8e] tracking-wide">OR</span>
          <div className="flex-1 h-px bg-[#dbdbdb]" />
        </div>

        <div className="text-center">
          <Link
            href="/forgot-password"
            className="text-[12px] text-[#385185] hover:text-[#1a3a6b]"
            data-testid="link-forgot-password"
          >
            Forgot password?
          </Link>
        </div>
      </form>
    </AuthShell>
  );
}

void basePath;
