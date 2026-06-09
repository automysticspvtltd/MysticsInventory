import { Router, type IRouter } from "express";
import { and, eq, inArray } from "drizzle-orm";
import PDFDocument from "pdfkit";
import { z } from "zod/v4";
import { db, itemsTable } from "@workspace/db";
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
    // Preserve caller-specified order; skip any ids that don't belong to org.
    const ordered = ids
      .map((id) => byId.get(id))
      .filter(<T,>(x: T | undefined): x is T => Boolean(x));
    if (ordered.length === 0) {
      res.status(404).json({ error: "No matching items" });
      return;
    }

    // Render all unique barcode PNGs once.
    const pngCache = new Map<number, Buffer>();
    for (const item of ordered) {
      const value = resolveBarcodeValue(item);
      const png = await renderBarcodePng(value, { scale: 2, height: 12 });
      pngCache.set(item.id, png);
    }

    // bufferPages: true lets us finalize pages explicitly and prevents
    // pdfkit from auto-flushing pages mid-stream, which avoids the
    // "blank trailing page" bug seen when cursor overflows a page.
    const doc = new PDFDocument({ size: "A4", margin: 28, bufferPages: true });
    res.setHeader("Content-Type", "application/pdf");
    res.setHeader(
      "Content-Disposition",
      `attachment; filename="barcode-labels.pdf"`,
    );
    doc.pipe(res);

    // 3 columns x 8 rows = 24 labels per A4 page (matches Avery L7160-ish).
    const COLS = 3;
    const ROWS = 8;
    const pageW = 595.28;
    const pageH = 841.89;
    const margin = 28;
    const cellW = (pageW - margin * 2) / COLS;
    const cellH = (pageH - margin * 2) / ROWS;
    const padX = 8;
    const padY = 6;

    let cellIndex = 0;
    for (const item of ordered) {
      for (let c = 0; c < copies; c++) {
        if (cellIndex > 0 && cellIndex % (COLS * ROWS) === 0) {
          doc.addPage();
        }
        const localIdx = cellIndex % (COLS * ROWS);
        const col = localIdx % COLS;
        const row = Math.floor(localIdx / COLS);
        const x = margin + col * cellW;
        const y = margin + row * cellH;
        const png = pngCache.get(item.id)!;
        const value = resolveBarcodeValue(item);
        const innerW = cellW - padX * 2;

        // Clip each label to its own cell rectangle so no content can
        // overflow into adjacent cells or push pdfkit's cursor past the
        // page boundary (which would trigger an unwanted blank page).
        doc.save();
        doc.rect(x, y, cellW, cellH).clip();

        doc
          .font("Helvetica-Bold")
          .fontSize(8)
          .fillColor("#0f172a")
          .text(item.name.slice(0, 60), x + padX, y + padY, {
            width: innerW,
            ellipsis: true,
            lineBreak: false,
          });

        try {
          doc.image(png, x + padX, y + padY + 12, {
            fit: [innerW, cellH - padY * 2 - 36],
            align: "center",
          });
        } catch {
          // Skip image if it fails — labels still print value text below.
        }

        doc
          .font("Helvetica")
          .fontSize(7)
          .fillColor("#334155")
          .text(value, x + padX, y + cellH - padY - 16, {
            width: innerW,
            align: "center",
            lineBreak: false,
            ellipsis: true,
          });

        const mrpNum = Number(item.purchasePrice);
        const saleNum = Number(item.salePrice);
        const hasMrp = Number.isFinite(mrpNum) && mrpNum > 0;
        const hasSale = Number.isFinite(saleNum) && saleNum > 0;
        if (hasMrp || hasSale) {
          const priceParts: string[] = [];
          if (hasMrp) priceParts.push(`MRP Rs.${mrpNum.toFixed(2)}`);
          if (hasSale) priceParts.push(`Sale Rs.${saleNum.toFixed(2)}`);
          doc
            .font("Helvetica-Bold")
            .fontSize(7)
            .fillColor("#0f172a")
            .text(priceParts.join("  "), x + padX, y + cellH - padY - 8, {
              width: innerW,
              align: "center",
              lineBreak: false,
            });
        }

        // Restore graphics state and reset cursor to the top of the
        // current page so pdfkit cannot auto-insert a blank page.
        doc.restore();
        doc.x = margin;
        doc.y = margin;

        cellIndex++;
      }
    }

    // Flush buffered pages to the output stream then close the document.
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

    // Batch-fetch all items by SKU up front to avoid N+1.
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

      // Validate prices.
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
