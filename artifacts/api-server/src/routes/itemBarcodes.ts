import { Router, type IRouter } from "express";
import { and, eq, inArray } from "drizzle-orm";
import PDFDocument from "pdfkit";
import { z } from "zod/v4";
import { db, itemsTable, organizationsTable } from "@workspace/db";
import { tenantMiddleware } from "../lib/tenant";
import { renderBarcodePng, resolveBarcodeValue } from "../lib/barcode";

const router: IRouter = Router();
router.use(tenantMiddleware);

router.get("/items/:id/barcode.png", async (req, res, next) => {
  try {
    const t = req.tenant!;
    const id = Number(req.params.id);
    if (!Number.isFinite(id) || id <= 0) {
      res.status(400).json({ error: "Invalid item id" });
      return;
    }
    const rows = await db
      .select({
        id: itemsTable.id,
        sku: itemsTable.sku,
        barcode: itemsTable.barcode,
      })
      .from(itemsTable)
      .where(
        and(
          eq(itemsTable.id, id),
          eq(itemsTable.organizationId, t.organizationId),
        ),
      )
      .limit(1);
    const item = rows[0];
    if (!item) {
      res.status(404).json({ error: "Item not found" });
      return;
    }
    const value = resolveBarcodeValue(item);
    const scale = clampInt(req.query.scale, 3, 1, 8);
    const height = clampInt(req.query.height, 14, 6, 40);
    const png = await renderBarcodePng(value, { scale, height });
    res.setHeader("Content-Type", "image/png");
    res.setHeader("Cache-Control", "private, max-age=300");
    res.setHeader("Content-Length", String(png.length));
    res.send(png);
  } catch (err) {
    next(err);
  }
});

// 50 mm × 25 mm in PostScript points (1 pt = 1/72 inch; 1 mm = 2.8346 pt)
const LABEL_W = 141.73; // 50 mm
const LABEL_H = 70.87; // 25 mm
const PAD_X = 5;
const PAD_Y = 4;
const INNER_W = LABEL_W - PAD_X * 2;

// ₹1,799.00 style — requires DejaVu font (Helvetica lacks U+20B9)
function labelPrice(n: number): string {
  return "\u20B9" + n.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

router.get("/items/barcode-labels.pdf", async (req, res, next) => {
  try {
    const t = req.tenant!;
    const ids = parseIds(req.query.ids);
    if (ids.length === 0) {
      res.status(400).json({ error: "Provide ids=1,2,3 (1-200)" });
      return;
    }
    if (ids.length > 200) {
      res.status(400).json({ error: "Maximum 200 distinct items per sheet" });
      return;
    }
    const copies = clampInt(req.query.copies, 1, 1, 50);

    const rows = await db
      .select({
        id: itemsTable.id,
        sku: itemsTable.sku,
        name: itemsTable.name,
        barcode: itemsTable.barcode,
        salePrice: itemsTable.salePrice,
        purchasePrice: itemsTable.purchasePrice,
      })
      .from(itemsTable)
      .where(
        and(
          inArray(itemsTable.id, ids),
          eq(itemsTable.organizationId, t.organizationId),
        ),
      );

    const byId = new Map(rows.map((r) => [r.id, r]));
    const ordered = ids
      .map((id) => byId.get(id))
      .filter(<T,>(x: T | undefined): x is T => Boolean(x));

    if (ordered.length === 0) {
      res.status(404).json({ error: "No matching items" });
      return;
    }

    // Fetch org logo URL
    let logoPng: Buffer | null = null;
    {
      const orgRows = await db
        .select({ logoUrl: organizationsTable.logoUrl, thermalLogoUrl: organizationsTable.thermalLogoUrl })
        .from(organizationsTable)
        .where(eq(organizationsTable.id, t.organizationId))
        .limit(1);
      const logoUrl = orgRows[0]?.thermalLogoUrl ?? orgRows[0]?.logoUrl ?? null;
      if (logoUrl && /^https?:\/\//i.test(logoUrl)) {
        try {
          const resp = await fetch(logoUrl, {
            signal: AbortSignal.timeout(3000),
          });
          if (resp.ok) {
            const ab = await resp.arrayBuffer();
            logoPng = Buffer.from(ab);
          }
        } catch {
          // Skip logo on fetch failure
        }
      }
    }

    // Pre-render barcode PNGs — bars only, no embedded human-readable text
    // (we draw the value as a separate centered line below the image)
    const pngCache = new Map<number, Buffer>();
    const valueCache = new Map<number, string>();
    for (const item of ordered) {
      const value = resolveBarcodeValue(item);
      valueCache.set(item.id, value);
      const png = await renderBarcodePng(value, {
        scale: 3,
        height: 20,
        includetext: false,
        paddingheight: 1,
      });
      pngCache.set(item.id, png);
    }

    const doc = new PDFDocument({
      size: [LABEL_W, LABEL_H],
      margin: 0,
      bufferPages: true,
    });

    // DejaVu Sans ships on this system and includes ₹ (U+20B9).
    // Built-in Helvetica uses WinAnsi encoding which lacks the rupee sign.
    doc.registerFont(
      "DV",
      "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    );
    doc.registerFont(
      "DV-Bold",
      "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    );

    res.setHeader("Content-Type", "application/pdf");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename="barcode-labels.pdf"`,
    );
    doc.pipe(res);

    let firstPage = true;
    for (const item of ordered) {
      for (let c = 0; c < copies; c++) {
        if (!firstPage) {
          doc.addPage({ size: [LABEL_W, LABEL_H], margin: 0 });
        }
        firstPage = false;

        const png = pngCache.get(item.id)!;

        doc.save();
        doc.rect(0, 0, LABEL_W, LABEL_H).clip();

        // ── Header: SKU (line 1) + Name (line 2) ───────────────────────
        let barcodeY: number;

        if (logoPng) {
          // Logo left (12×12 pt), name to its right
          try {
            doc.image(logoPng, PAD_X, PAD_Y, { width: 12, height: 12 });
          } catch {
            // Skip logo if PDFKit can't read the image format
          }
          doc
            .font("DV-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(item.name.slice(0, 45), PAD_X + 14, PAD_Y + 2, {
              width: INNER_W - 14,
              align: "center",
              lineBreak: false,
              ellipsis: true,
            });
          barcodeY = PAD_Y + 15;
        } else {
          // Line 1: SKU — small, centered
          doc
            .font("DV")
            .fontSize(6)
            .fillColor("#222222")
            .text(item.sku.slice(0, 60), PAD_X, PAD_Y, {
              width: INNER_W,
              align: "center",
              lineBreak: false,
              ellipsis: true,
            });
          // Line 2: Product name — bold, centered
          doc
            .font("DV-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(item.name.slice(0, 55), PAD_X, PAD_Y + 8, {
              width: INNER_W,
              align: "center",
              lineBreak: false,
              ellipsis: true,
            });
          barcodeY = PAD_Y + 17;
        }

        // ── Barcode bars + number ───────────────────────────────────────
        const priceY = LABEL_H - PAD_Y - 9;
        const barcodeValueY = priceY - 10;
        const barcodeH = barcodeValueY - barcodeY - 2;

        try {
          doc.image(png, PAD_X, barcodeY, {
            fit: [INNER_W, barcodeH],
            align: "center",
          });
        } catch {
          // Skip image if it fails
        }

        const barcodeValue = valueCache.get(item.id) ?? "";
        doc
          .font("DV")
          .fontSize(6)
          .fillColor("#333333")
          .text(barcodeValue, PAD_X, barcodeValueY, {
            width: INNER_W,
            align: "center",
            lineBreak: false,
            ellipsis: true,
          });

        // ── Price row: Sale LEFT (bold black) | MRP RIGHT (gray + strikethrough)
        const mrpNum = Number(item.purchasePrice);
        const saleNum = Number(item.salePrice);
        const hasMrp = Number.isFinite(mrpNum) && mrpNum > 0;
        const hasSale = Number.isFinite(saleNum) && saleNum > 0;

        if (hasMrp && hasSale) {
          const saleStr = labelPrice(saleNum);
          const mrpStr = labelPrice(mrpNum);

          // Measure widths at the correct font/size first
          doc.font("DV-Bold").fontSize(7);
          const saleW = doc.widthOfString(saleStr);
          doc.font("DV").fontSize(7);
          const mrpW = doc.widthOfString(mrpStr);

          // Sale price — flush left, bold black
          doc
            .font("DV-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(saleStr, PAD_X, priceY, { lineBreak: false });

          // MRP — flush right, gray
          const mrpX = LABEL_W - PAD_X - mrpW;
          doc
            .font("DV")
            .fontSize(7)
            .fillColor("#888888")
            .text(mrpStr, mrpX, priceY, { lineBreak: false });

          // Strikethrough through the visual centre of MRP text
          doc
            .moveTo(mrpX, priceY + 3.5)
            .lineTo(mrpX + mrpW, priceY + 3.5)
            .strokeColor("#555555")
            .lineWidth(0.7)
            .stroke();

          void saleW;
        } else if (hasSale) {
          doc
            .font("DV-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(labelPrice(saleNum), PAD_X, priceY, {
              width: INNER_W,
              align: "center",
              lineBreak: false,
            });
        } else if (hasMrp) {
          doc
            .font("DV-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(labelPrice(mrpNum), PAD_X, priceY, {
              width: INNER_W,
              align: "center",
              lineBreak: false,
            });
        }

        doc.restore();
        doc.x = 0;
        doc.y = 0;
      }
    }

    doc.flushPages();
    doc.end();
  } catch (err) {
    next(err);
  }
});

const BarcodeImportRowSchema = z.object({
  sku: z.string().min(1, "SKU is required"),
  barcode: z.string().nullish(),
  salePrice: z.string().nullish(),
  purchasePrice: z.string().nullish(),
});

const BarcodeImportBodySchema = z.object({
  rows: z.array(BarcodeImportRowSchema).min(1).max(1000),
});

router.post("/items/barcode-import", async (req, res, next) => {
  try {
    const t = req.tenant!;
    const parsed = BarcodeImportBodySchema.safeParse(req.body);
    if (!parsed.success) {
      res.status(400).json({ error: "Invalid request body" });
      return;
    }
    const { rows } = parsed.data;

    const skus = [...new Set(rows.map((r) => r.sku.trim()).filter(Boolean))];
    const existingItems = await db
      .select({ id: itemsTable.id, sku: itemsTable.sku })
      .from(itemsTable)
      .where(
        and(
          inArray(itemsTable.sku, skus),
          eq(itemsTable.organizationId, t.organizationId),
        ),
      );
    const itemBySku = new Map(existingItems.map((i) => [i.sku, i.id]));

    let updated = 0;
    let failed = 0;
    const errors: string[] = [];

    for (const row of rows) {
      const sku = row.sku.trim();

      let salePriceStr: string | undefined;
      let purchasePriceStr: string | undefined;

      if (row.salePrice != null && row.salePrice !== "") {
        const n = Number(row.salePrice);
        if (!Number.isFinite(n) || n < 0) {
          errors.push(`SKU "${sku}": Sales Price must be a non-negative number`);
          failed++;
          continue;
        }
        salePriceStr = String(n);
      }
      if (row.purchasePrice != null && row.purchasePrice !== "") {
        const n = Number(row.purchasePrice);
        if (!Number.isFinite(n) || n < 0) {
          errors.push(`SKU "${sku}": MRP must be a non-negative number`);
          failed++;
          continue;
        }
        purchasePriceStr = String(n);
      }

      const itemId = itemBySku.get(sku);
      if (!itemId) {
        errors.push(`SKU "${sku}" not found`);
        failed++;
        continue;
      }

      const updateFields: {
        barcode?: string;
        salePrice?: string;
        purchasePrice?: string;
      } = {};
      if (row.barcode != null && row.barcode.trim() !== "") {
        updateFields.barcode = row.barcode.trim();
      }
      if (salePriceStr !== undefined) updateFields.salePrice = salePriceStr;
      if (purchasePriceStr !== undefined) updateFields.purchasePrice = purchasePriceStr;

      if (Object.keys(updateFields).length > 0) {
        await db
          .update(itemsTable)
          .set(updateFields)
          .where(
            and(
              eq(itemsTable.id, itemId),
              eq(itemsTable.organizationId, t.organizationId),
            ),
          );
      }
      updated++;
    }

    res.json({ updated, failed, errors });
  } catch (err) {
    next(err);
  }
});

function clampInt(
  raw: unknown,
  fallback: number,
  min: number,
  max: number,
): number {
  const n = Number(raw);
  if (!Number.isFinite(n)) return fallback;
  return Math.max(min, Math.min(max, Math.floor(n)));
}

function parseIds(raw: unknown): number[] {
  if (typeof raw !== "string" || raw.trim() === "") return [];
  const out: number[] = [];
  const seen = new Set<number>();
  for (const part of raw.split(",")) {
    const n = Number(part.trim());
    if (Number.isFinite(n) && n > 0 && Number.isInteger(n) && !seen.has(n)) {
      seen.add(n);
      out.push(n);
    }
  }
  return out;
}

export default router;
