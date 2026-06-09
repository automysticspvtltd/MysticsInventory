import { useMemo, useRef, useState } from "react";
import Papa from "papaparse";
import * as XLSX from "xlsx";
import { useQueryClient } from "@tanstack/react-query";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useToast } from "@/hooks/use-toast";
import {
  customFetch,
  getListItemsQueryKey,
} from "@/lib/queryKeys";
import { cn } from "@/lib/utils";
import {
  AlertCircle,
  CheckCircle2,
  Download,
  FileSpreadsheet,
  Info,
  Loader2,
  Upload,
  X,
} from "lucide-react";

const MAX_ROWS = 500;

type VariantImportRow = {
  parentSku: string;
  variantName: string;
  sku: string;
  barcode: string;
  purchasePrice: string;
  salePrice: string;
  totalStock: string;
  attr1: string;
  attr2: string;
  attr3: string;
};

type VariantResultRow = {
  index: number;
  sku: string;
  parentSku: string;
  action: "create" | "skip" | "error";
  error?: string;
};

type VariantImportResponse = {
  results: VariantResultRow[];
  counts: { create: number; skip: number; error: number };
};

const HEADER_ALIASES: Record<string, keyof VariantImportRow> = {
  "parent item": "parentSku",
  "parentitem": "parentSku",
  "parent sku": "parentSku",
  "parentsku": "parentSku",
  "parent": "parentSku",
  "variant name": "variantName",
  "variantname": "variantName",
  "name": "variantName",
  "sku": "sku",
  "barcode": "barcode",
  "ean": "barcode",
  "upc": "barcode",
  "mrp": "purchasePrice",
  "purchase price": "purchasePrice",
  "purchaseprice": "purchasePrice",
  "cost price": "purchasePrice",
  "costprice": "purchasePrice",
  "sale price": "salePrice",
  "saleprice": "salePrice",
  "selling price": "salePrice",
  "sellingprice": "salePrice",
  "price": "salePrice",
  "stock": "totalStock",
  "total stock": "totalStock",
  "totalstock": "totalStock",
  "quantity": "totalStock",
  "opening stock": "totalStock",
  "attribute 1": "attr1",
  "attribute1": "attr1",
  "attr 1": "attr1",
  "attr1": "attr1",
  "attribute 2": "attr2",
  "attribute2": "attr2",
  "attr 2": "attr2",
  "attr2": "attr2",
  "attribute 3": "attr3",
  "attribute3": "attr3",
  "attr 3": "attr3",
  "attr3": "attr3",
};

function normaliseHeader(h: string): string {
  return h.toLowerCase().replace(/[^a-z0-9]+/g, " ").trim();
}

function buildRow(raw: Partial<VariantImportRow>): VariantImportRow {
  return {
    parentSku: String(raw.parentSku ?? "").trim(),
    variantName: String(raw.variantName ?? "").trim(),
    sku: String(raw.sku ?? "").trim(),
    barcode: String(raw.barcode ?? "").trim(),
    purchasePrice: String(raw.purchasePrice ?? "").trim(),
    salePrice: String(raw.salePrice ?? "").trim(),
    totalStock: String(raw.totalStock ?? "").trim(),
    attr1: String(raw.attr1 ?? "").trim(),
    attr2: String(raw.attr2 ?? "").trim(),
    attr3: String(raw.attr3 ?? "").trim(),
  };
}

function processHeadersAndData(
  headers: string[],
  rawData: Record<string, string>[],
): { rows: VariantImportRow[]; warnings: string[] } {
  const warnings: string[] = [];
  const headerMap: Record<string, keyof VariantImportRow> = {};
  for (const h of headers) {
    const normal = normaliseHeader(h);
    const target = HEADER_ALIASES[normal];
    if (target) headerMap[h] = target;
  }
  if (!Object.values(headerMap).includes("parentSku")) {
    throw new Error(
      'File is missing a "Parent Item" column. Download the template to see required headers.',
    );
  }
  if (!Object.values(headerMap).includes("sku")) {
    throw new Error(
      'File is missing a "SKU" column. Download the template to see required headers.',
    );
  }
  const ignoredHeaders = headers.filter((h) => !headerMap[h]);
  if (ignoredHeaders.length > 0) {
    warnings.push(
      `Ignored unknown column${ignoredHeaders.length > 1 ? "s" : ""}: ${ignoredHeaders.join(", ")}`,
    );
  }
  const rows: VariantImportRow[] = [];
  for (const raw of rawData) {
    const out: Partial<VariantImportRow> = {};
    let touched = false;
    for (const [csvHeader, target] of Object.entries(headerMap)) {
      const value = raw[csvHeader];
      if (value !== undefined && value !== null && value !== "") touched = true;
      (out as Record<string, unknown>)[target] = value ?? "";
    }
    if (!touched) continue;
    rows.push(buildRow(out));
  }
  return { rows, warnings };
}

function parseCsvFile(
  file: File,
): Promise<{ rows: VariantImportRow[]; warnings: string[] }> {
  return new Promise((resolve, reject) => {
    Papa.parse<Record<string, string>>(file, {
      header: true,
      skipEmptyLines: "greedy",
      transformHeader: (h) => h.trim(),
      complete: (result) => {
        try {
          const headers = result.meta.fields ?? [];
          resolve(processHeadersAndData(headers, result.data));
        } catch (err) {
          reject(err);
        }
      },
      error: (err) => reject(err),
    });
  });
}

function parseXlsxFile(
  file: File,
): Promise<{ rows: VariantImportRow[]; warnings: string[] }> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = (e) => {
      try {
        const data = new Uint8Array(e.target!.result as ArrayBuffer);
        const wb = XLSX.read(data, { type: "array" });
        const sheet = wb.Sheets[wb.SheetNames[0]];
        if (!sheet) {
          reject(new Error("Excel file contains no sheets."));
          return;
        }
        const aoa = XLSX.utils.sheet_to_json<(string | number | null)[]>(sheet, {
          header: 1,
          defval: null,
          blankrows: false,
        });
        let headerRowIdx = -1;
        for (let i = 0; i < Math.min(aoa.length, 10); i++) {
          const rowNorm = aoa[i].map((v) => normaliseHeader(String(v ?? "")));
          if (rowNorm.some((n) => HEADER_ALIASES[n] !== undefined)) {
            headerRowIdx = i;
            break;
          }
        }
        if (headerRowIdx === -1) {
          reject(
            new Error(
              "Could not find a recognised header row. Download the template to see required columns.",
            ),
          );
          return;
        }
        const headers = aoa[headerRowIdx].map((v) => String(v ?? "").trim());
        const rawData: Record<string, string>[] = aoa
          .slice(headerRowIdx + 1)
          .map((row) => {
            const obj: Record<string, string> = {};
            headers.forEach((h, i) => {
              obj[h] = String(row[i] ?? "").trim();
            });
            return obj;
          });
        resolve(processHeadersAndData(headers, rawData));
      } catch (err) {
        reject(err instanceof Error ? err : new Error("Failed to read Excel file."));
      }
    };
    reader.onerror = () => reject(new Error("Failed to read file."));
    reader.readAsArrayBuffer(file);
  });
}

function downloadTemplate() {
  const wb = XLSX.utils.book_new();
  const headers = [
    "Parent Item",
    "Variant Name",
    "SKU",
    "Barcode",
    "MRP",
    "Sale Price",
    "Stock",
    "Attribute 1",
    "Attribute 2",
    "Attribute 3",
  ];
  const sample = [
    ["TSHIRT-001", "T-Shirt Red Large", "TSHIRT-RED-L", "", "299", "249", "10", "Red", "Large", ""],
    ["TSHIRT-001", "T-Shirt Blue Medium", "TSHIRT-BLUE-M", "", "299", "249", "5", "Blue", "Medium", ""],
  ];
  const ws = XLSX.utils.aoa_to_sheet([headers, ...sample]);
  ws["!cols"] = headers.map((h) => ({ wch: Math.max(h.length + 4, 14) }));
  XLSX.utils.book_append_sheet(wb, ws, "Variant Import");
  XLSX.writeFile(wb, "variant-import-template.xlsx");
}

interface BulkImportVariantsDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function BulkImportVariantsDialog({
  open,
  onOpenChange,
}: BulkImportVariantsDialogProps) {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  const [fileName, setFileName] = useState<string | null>(null);
  const [rows, setRows] = useState<VariantImportRow[]>([]);
  const [warnings, setWarnings] = useState<string[]>([]);
  const [results, setResults] = useState<VariantResultRow[] | null>(null);
  const [counts, setCounts] = useState<VariantImportResponse["counts"] | null>(null);
  const [parsing, setParsing] = useState(false);
  const [validating, setValidating] = useState(false);
  const [committing, setCommitting] = useState(false);
  const [topLevelError, setTopLevelError] = useState<string | null>(null);

  const errorRows = useMemo(
    () => results?.filter((r) => r.action === "error") ?? [],
    [results],
  );

  function reset() {
    setFileName(null);
    setRows([]);
    setWarnings([]);
    setResults(null);
    setCounts(null);
    setTopLevelError(null);
    setParsing(false);
    setValidating(false);
    setCommitting(false);
    if (fileInputRef.current) fileInputRef.current.value = "";
  }

  function handleClose() {
    if (committing) return;
    reset();
    onOpenChange(false);
  }

  async function handleFile(file: File) {
    setParsing(true);
    setTopLevelError(null);
    setResults(null);
    setCounts(null);
    try {
      const isXlsx =
        file.name.toLowerCase().endsWith(".xlsx") ||
        file.name.toLowerCase().endsWith(".xls");
      const { rows: parsed, warnings: parseWarnings } = await (isXlsx
        ? parseXlsxFile(file)
        : parseCsvFile(file));
      if (parsed.length === 0) {
        setTopLevelError("No data rows found in the file.");
        setRows([]);
        setWarnings(parseWarnings);
        return;
      }
      if (parsed.length > MAX_ROWS) {
        setTopLevelError(
          `Maximum ${MAX_ROWS} rows per import. Your file has ${parsed.length} rows — please split it.`,
        );
        setRows([]);
        setWarnings(parseWarnings);
        return;
      }
      setRows(parsed);
      setFileName(file.name);
      setWarnings(parseWarnings);
      await runDryRun(parsed);
    } catch (err) {
      setTopLevelError(err instanceof Error ? err.message : "Failed to read file");
      setRows([]);
    } finally {
      setParsing(false);
    }
  }

  async function runDryRun(currentRows: VariantImportRow[]) {
    setValidating(true);
    setTopLevelError(null);
    try {
      const resp = await customFetch<VariantImportResponse>(
        "/api/items/variant-bulk-import",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ dryRun: true, rows: currentRows }),
        },
      );
      setResults(resp.results);
      setCounts(resp.counts);
    } catch (err) {
      const body = (err as { data?: VariantImportResponse | null })?.data;
      if (body && Array.isArray(body.results)) {
        setResults(body.results);
        setCounts(body.counts);
      } else {
        setTopLevelError(
          err instanceof Error ? err.message : "Failed to validate rows",
        );
      }
    } finally {
      setValidating(false);
    }
  }

  async function handleCommit() {
    if (rows.length === 0 || errorRows.length > 0) return;
    setCommitting(true);
    setTopLevelError(null);
    try {
      const resp = await customFetch<VariantImportResponse>(
        "/api/items/variant-bulk-import",
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ dryRun: false, rows }),
        },
      );
      setResults(resp.results);
      setCounts(resp.counts);
      toast({
        title: "Variants imported",
        description: `${resp.counts.create} created, ${resp.counts.skip} skipped.`,
      });
      queryClient.invalidateQueries({ queryKey: getListItemsQueryKey() });
      reset();
      onOpenChange(false);
    } catch (err) {
      const body = (err as { data?: VariantImportResponse | null })?.data;
      if (body && Array.isArray(body.results)) {
        setResults(body.results);
        setCounts(body.counts);
      }
      toast({
        title: "Import failed",
        description:
          err instanceof Error ? err.message : "Unable to import variants",
        variant: "destructive",
      });
    } finally {
      setCommitting(false);
    }
  }

  const hasFile = rows.length > 0;
  const canCommit =
    hasFile && !validating && !committing && errorRows.length === 0;

  return (
    <Dialog
      open={open}
      onOpenChange={(v) => (v ? onOpenChange(true) : handleClose())}
    >
      <DialogContent className="max-w-3xl max-h-[90vh] flex flex-col overflow-hidden">
        <DialogHeader className="shrink-0">
          <DialogTitle>Import variant products</DialogTitle>
          <DialogDescription>
            Upload a CSV or Excel (.xlsx) file. Required columns:{" "}
            <code className="font-mono">Parent Item</code> (parent's SKU) and{" "}
            <code className="font-mono">SKU</code>. Attribute columns map to
            the parent item's axes in order.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4 flex-1 overflow-y-auto min-h-0 pr-1">
          <div className="flex flex-wrap items-center gap-3">
            <input
              ref={fileInputRef}
              type="file"
              accept=".csv,.xlsx,.xls,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
              className="hidden"
              data-testid="input-variant-import-file"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) void handleFile(file);
              }}
            />
            <Button
              type="button"
              variant="outline"
              onClick={() => fileInputRef.current?.click()}
              disabled={parsing || validating || committing}
              data-testid="btn-variant-import-choose-file"
            >
              <Upload className="mr-2 h-4 w-4" />
              {hasFile ? "Choose another file" : "Choose CSV or Excel file"}
            </Button>
            <Button
              type="button"
              variant="ghost"
              onClick={downloadTemplate}
              data-testid="btn-variant-import-template"
            >
              <Download className="mr-2 h-4 w-4" />
              Download template
            </Button>
            {fileName && (
              <div className="flex items-center gap-2 text-sm text-muted-foreground">
                <FileSpreadsheet className="h-4 w-4" />
                <span className="font-medium text-foreground">{fileName}</span>
                <span>·</span>
                <span>{rows.length} rows</span>
                <button
                  type="button"
                  onClick={reset}
                  className="ml-1 text-muted-foreground hover:text-foreground"
                  aria-label="Clear file"
                >
                  <X className="h-3.5 w-3.5" />
                </button>
              </div>
            )}
          </div>

          <Alert variant="default" className="bg-muted/50 border-muted">
            <Info className="h-4 w-4" />
            <AlertDescription className="text-xs space-y-1">
              <p>
                <strong>Parent Item</strong> — the SKU of an existing item with
                "Has Variants" enabled (e.g. <code>TSHIRT-001</code>).
              </p>
              <p>
                <strong>Attribute 1 / 2 / 3</strong> — values for the parent's
                variant axes in order (e.g. if axes are Color, Size then
                Attribute 1 = Color value, Attribute 2 = Size value).
              </p>
              <p>
                Rows whose SKU already exists are skipped. Leave Barcode blank
                to auto-generate.
              </p>
            </AlertDescription>
          </Alert>

          {(parsing || validating) && (
            <div className="flex items-center gap-2 text-sm text-muted-foreground">
              <Loader2 className="h-4 w-4 animate-spin" />
              {parsing ? "Reading file…" : "Validating rows…"}
            </div>
          )}

          {topLevelError && (
            <Alert variant="destructive">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>{topLevelError}</AlertDescription>
            </Alert>
          )}

          {warnings.length > 0 && (
            <Alert>
              <Info className="h-4 w-4" />
              <AlertDescription>
                {warnings.map((w, i) => (
                  <p key={i}>{w}</p>
                ))}
              </AlertDescription>
            </Alert>
          )}

          {counts && (
            <div className="flex flex-wrap gap-2 text-sm">
              <span className="flex items-center gap-1.5">
                <Badge variant="default">{counts.create}</Badge>
                <span className="text-muted-foreground">
                  to create
                </span>
              </span>
              {counts.skip > 0 && (
                <span className="flex items-center gap-1.5">
                  <Badge variant="secondary">{counts.skip}</Badge>
                  <span className="text-muted-foreground">skipped</span>
                </span>
              )}
              {counts.error > 0 && (
                <span className="flex items-center gap-1.5">
                  <Badge variant="destructive">{counts.error}</Badge>
                  <span className="text-muted-foreground">errors</span>
                </span>
              )}
            </div>
          )}

          {results && results.length > 0 && (
            <ScrollArea className="h-56 rounded-md border">
              <table className="w-full text-xs">
                <thead className="sticky top-0 bg-muted/80 backdrop-blur-sm">
                  <tr>
                    <th className="py-2 px-3 text-left font-medium">#</th>
                    <th className="py-2 px-3 text-left font-medium">Parent SKU</th>
                    <th className="py-2 px-3 text-left font-medium">Variant SKU</th>
                    <th className="py-2 px-3 text-left font-medium">Status</th>
                    <th className="py-2 px-3 text-left font-medium">Note</th>
                  </tr>
                </thead>
                <tbody>
                  {results.map((r) => (
                    <tr
                      key={r.index}
                      className={cn(
                        "border-t",
                        r.action === "error" && "bg-destructive/5",
                        r.action === "skip" && "bg-muted/30",
                      )}
                    >
                      <td className="py-1.5 px-3 text-muted-foreground">
                        {r.index}
                      </td>
                      <td className="py-1.5 px-3 font-mono">{r.parentSku}</td>
                      <td className="py-1.5 px-3 font-mono">{r.sku}</td>
                      <td className="py-1.5 px-3">
                        {r.action === "create" && (
                          <span className="flex items-center gap-1 text-emerald-600">
                            <CheckCircle2 className="h-3 w-3" />
                            Create
                          </span>
                        )}
                        {r.action === "skip" && (
                          <span className="text-muted-foreground">Skip</span>
                        )}
                        {r.action === "error" && (
                          <span className="flex items-center gap-1 text-destructive">
                            <AlertCircle className="h-3 w-3" />
                            Error
                          </span>
                        )}
                      </td>
                      <td className="py-1.5 px-3 text-muted-foreground">
                        {r.error ?? "—"}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </ScrollArea>
          )}
        </div>

        <DialogFooter className="shrink-0 pt-2">
          <Button variant="outline" onClick={handleClose} disabled={committing}>
            Cancel
          </Button>
          <Button
            onClick={() => void handleCommit()}
            disabled={!canCommit}
            data-testid="btn-variant-import-commit"
          >
            {committing ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Importing…
              </>
            ) : (
              `Import ${counts?.create ?? 0} variant${(counts?.create ?? 0) !== 1 ? "s" : ""}`
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
