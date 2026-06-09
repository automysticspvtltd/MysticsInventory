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
        .select({ logoUrl: organizationsTable.logoUrl })
        .from(organizationsTable)
        .where(eq(organizationsTable.id, t.organizationId))
        .limit(1);
      const logoUrl = orgRows[0]?.logoUrl ?? null;
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

    // Pre-render barcode PNGs
    const pngCache = new Map<number, Buffer>();
    for (const item of ordered) {
      const value = resolveBarcodeValue(item);
      const png = await renderBarcodePng(value, { scale: 3, height: 20 });
      pngCache.set(item.id, png);
    }

    const doc = new PDFDocument({
      size: [LABEL_W, LABEL_H],
      margin: 0,
      bufferPages: true,
    });

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

        // Clip to page bounds
        doc.save();
        doc.rect(0, 0, LABEL_W, LABEL_H).clip();

        let barcodeY: number;

        if (logoPng) {
          // Logo (12 × 12 pt) in top-left, item name to its right
          try {
            doc.image(logoPng, PAD_X, PAD_Y, { width: 12, height: 12 });
          } catch {
            // Skip logo if PDFKit can't read the image format
          }
          doc
            .font("Helvetica-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(item.name.slice(0, 45), PAD_X + 14, PAD_Y + 2, {
              width: INNER_W - 14,
              lineBreak: false,
              ellipsis: true,
            });
          barcodeY = PAD_Y + 14;
        } else {
          doc
            .font("Helvetica-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(item.name.slice(0, 55), PAD_X, PAD_Y, {
              width: INNER_W,
              lineBreak: false,
              ellipsis: true,
            });
          barcodeY = PAD_Y + 10;
        }

        // Price line sits near the bottom
        const priceY = LABEL_H - PAD_Y - 9;
        const barcodeH = priceY - barcodeY - 3;

        // Barcode image (no value text — the bars speak for themselves)
        try {
          doc.image(png, PAD_X, barcodeY, {
            fit: [INNER_W, barcodeH],
            align: "center",
          });
        } catch {
          // Skip image if it fails
        }

        // Price line: MRP with strikethrough + Sale Price bold
        const mrpNum = Number(item.purchasePrice);
        const saleNum = Number(item.salePrice);
        const hasMrp = Number.isFinite(mrpNum) && mrpNum > 0;
        const hasSale = Number.isFinite(saleNum) && saleNum > 0;

        if (hasMrp && hasSale) {
          const mrpStr = `MRP \u20B9${mrpNum.toFixed(0)}`;
          const saleStr = `  \u20B9${saleNum.toFixed(0)}`;

          doc.font("Helvetica").fontSize(6).fillColor("#888888");
          const mrpW = doc.widthOfString(mrpStr);

          doc.font("Helvetica-Bold").fontSize(7).fillColor("#000000");
          const saleW = doc.widthOfString(saleStr);

          const totalW = mrpW + saleW;
          const startX = PAD_X + Math.max(0, (INNER_W - totalW) / 2);

          doc
            .font("Helvetica")
            .fontSize(6)
            .fillColor("#888888")
            .text(mrpStr, startX, priceY, { lineBreak: false });

          // Strikethrough line over MRP text
          doc
            .moveTo(startX, priceY + 2.5)
            .lineTo(startX + mrpW, priceY + 2.5)
            .strokeColor("#888888")
            .lineWidth(0.4)
            .stroke();

          doc
            .font("Helvetica-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(saleStr, startX + mrpW, priceY, { lineBreak: false });
        } else if (hasMrp) {
          const mrpStr = `MRP \u20B9${mrpNum.toFixed(0)}`;
          doc
            .font("Helvetica-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(mrpStr, PAD_X, priceY, {
              width: INNER_W,
              align: "center",
              lineBreak: false,
            });
        } else if (hasSale) {
          const saleStr = `\u20B9${saleNum.toFixed(0)}`;
          doc
            .font("Helvetica-Bold")
            .fontSize(7)
            .fillColor("#000000")
            .text(saleStr, PAD_X, priceY, {
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
