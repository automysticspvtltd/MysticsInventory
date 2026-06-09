import { useMemo, useRef, useState } from "react";
import Papa from "papaparse";
import * as XLSX from "xlsx";
import {
  AlertCircle,
  CheckCircle2,
  Download,
  FileSpreadsheet,
  Loader2,
  Upload,
  X,
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import {
  RadioGroup,
  RadioGroupItem,
} from "@/components/ui/radio-group";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { useToast } from "@/hooks/use-toast";
import { useQueryClient } from "@tanstack/react-query";
import {
  bulkImportItems,
  getListItemsQueryKey,
  type BulkImportItemRow,
  type BulkImportResultRow,
  type BulkImportItemsResponse,
} from "@workspace/api-client-react";
import { cn } from "@/lib/utils";

interface BulkImportItemsDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

type Mode = "create" | "upsert";

const TEMPLATE_HEADERS = [
  "Name",
  "SKU",
  "Description",
  "Category",
  "Unit",
  "Sale Price",
  "MRP",
  "Tax Rate %",
  "HSN Code",
  "Barcode",
  "Min Stock Level",
  "Max Discount (%)",
  "Max Discount (₹)",
  "Total Stock",
] as const;

const TEMPLATE_DATA = [
  [
    "Sample Widget",
    "WIDGET-001",
    "Demo description (optional)",
    "Demo",
    "pcs",
    "199",
    "120",
    "18",
    "3926",
    "8901234567894",
    "10",
    "",
    "",
    "50",
  ],
];

const MAX_ROWS = 1000;

function buildTemplateCsv(): string {
  return Papa.unparse(
    {
      fields: [...TEMPLATE_HEADERS],
      data: TEMPLATE_DATA,
    },
    { quotes: true },
  );
}

function downloadTemplate() {
  const csv = buildTemplateCsv();
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = "items-import-template.csv";
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

function normaliseHeader(h: string): string {
  return h.trim().replace(/\s+/g, "").toLowerCase();
}

const HEADER_ALIASES: Record<string, keyof BulkImportItemRow> = {
  sku: "sku",
  name: "name",
  itemname: "name",
  productname: "name",
  description: "description",
  category: "category",
  unit: "unit",
  uom: "unit",
  saleprice: "salePrice",
  sellingprice: "salePrice",
  mrp: "purchasePrice",
  purchaseprice: "purchasePrice",
  costprice: "purchasePrice",
  cost: "purchasePrice",
  hsncode: "hsnCode",
  hsn: "hsnCode",
  barcode: "barcode",
  ean: "barcode",
  upc: "barcode",
  gtin: "barcode",
  taxrate: "taxRate",
  "taxrate%": "taxRate",
  gst: "taxRate",
  gstrate: "taxRate",
  reorderlevel: "reorderLevel",
  minstocklevel: "reorderLevel",
  reorder: "reorderLevel",
  totalstock: "totalStock",
  "maxdiscount(%)": "maxDiscountPercent",
  maxdiscountpercent: "maxDiscountPercent",
  maxdiscount: "maxDiscountPercent",
  "maxdiscount(rs)": "maxDiscountPercent",
  "maxdiscount(₹)": "maxDiscountAmount",
  maxdiscountamount: "maxDiscountAmount",
  "maxdiscountamount(₹)": "maxDiscountAmount",
};

function buildRow(out: Partial<BulkImportItemRow>): BulkImportItemRow {
  const str = (v: unknown) => (v != null && String(v).trim() !== "" ? String(v).trim() : null);
  return {
    sku: String(out.sku ?? "").trim(),
    name: String(out.name ?? "").trim(),
    description: str(out.description),
    category: str(out.category),
    unit: str(out.unit),
    salePrice: str(out.salePrice),
    purchasePrice: str(out.purchasePrice),
    hsnCode: str(out.hsnCode),
    barcode: str(out.barcode),
    taxRate: str(out.taxRate),
    reorderLevel: str(out.reorderLevel),
    maxDiscountPercent: str(out.maxDiscountPercent),
    maxDiscountAmount: str(out.maxDiscountAmount),
    totalStock: str(out.totalStock),
  };
}

function processHeadersAndData(
  headers: string[],
  rawData: Record<string, string>[],
): { rows: BulkImportItemRow[]; warnings: string[] } {
  const warnings: string[] = [];
  const headerMap: Record<string, keyof BulkImportItemRow> = {};
  for (const h of headers) {
    const normal = normaliseHeader(h);
    const target = HEADER_ALIASES[normal];
    if (target) headerMap[h] = target;
  }
  if (!Object.values(headerMap).includes("sku")) {
    throw new Error(
      "File is missing a `SKU` column. Download the template to see the required headers.",
    );
  }
  if (!Object.values(headerMap).includes("name")) {
    throw new Error(
      "File is missing a `Name` column. Download the template to see the required headers.",
    );
  }
  const ignoredHeaders = headers.filter((h) => !headerMap[h]);
  if (ignoredHeaders.length > 0) {
    warnings.push(
      `Ignored unknown column${
        ignoredHeaders.length > 1 ? "s" : ""
      }: ${ignoredHeaders.join(", ")}`,
    );
  }
  const rows: BulkImportItemRow[] = [];
  for (const raw of rawData) {
    const out: Partial<BulkImportItemRow> = {};
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
): Promise<{ rows: BulkImportItemRow[]; warnings: string[] }> {
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
): Promise<{ rows: BulkImportItemRow[]; warnings: string[] }> {
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
        // Find first row that contains a recognised column
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
              "Could not find a recognised header row in the Excel file. Download the template to see the required columns.",
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

export function BulkImportItemsDialog({
  open,
  onOpenChange,
}: BulkImportItemsDialogProps) {
  const { toast } = useToast();
  const queryClient = useQueryClient();
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  const [fileName, setFileName] = useState<string | null>(null);
  const [rows, setRows] = useState<BulkImportItemRow[]>([]);
  const [warnings, setWarnings] = useState<string[]>([]);
  const [mode, setMode] = useState<Mode>("create");
  const [results, setResults] = useState<BulkImportResultRow[] | null>(null);
  const [counts, setCounts] = useState<
    BulkImportItemsResponse["counts"] | null
  >(null);
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
      // Run a dry-run for instant feedback.
      await runDryRun(parsed, mode);
    } catch (err) {
      setTopLevelError(
        err instanceof Error ? err.message : "Failed to read CSV file",
      );
      setRows([]);
    } finally {
      setParsing(false);
    }
  }

  async function runDryRun(currentRows: BulkImportItemRow[], currentMode: Mode) {
    setValidating(true);
    setTopLevelError(null);
    try {
      const resp = await bulkImportItems({
        mode: currentMode,
        dryRun: true,
        rows: currentRows,
      });
      setResults(resp.results);
      setCounts(resp.counts);
    } catch (err) {
      // Server returns 400 with a populated body when there are row errors;
      // customFetch throws ApiError, exposing the parsed body on `data`.
      const body = (err as { data?: BulkImportItemsResponse | null })?.data;
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

  async function handleModeChange(next: Mode) {
    setMode(next);
    if (rows.length > 0) {
      await runDryRun(rows, next);
    }
  }

  async function handleCommit() {
    if (rows.length === 0) return;
    if (errorRows.length > 0) return;
    setCommitting(true);
    setTopLevelError(null);
    try {
      const resp = await bulkImportItems({
        mode,
        dryRun: false,
        rows,
      });
      setResults(resp.results);
      setCounts(resp.counts);
      toast({
        title: "Items imported",
        description: `${resp.counts.create} created, ${resp.counts.update} updated.`,
      });
      queryClient.invalidateQueries({ queryKey: getListItemsQueryKey() });
      reset();
      onOpenChange(false);
    } catch (err) {
      const body = (err as { data?: BulkImportItemsResponse | null })?.data;
      if (body && Array.isArray(body.results)) {
        setResults(body.results);
        setCounts(body.counts);
      }
      toast({
        title: "Import failed",
        description:
          err instanceof Error ? err.message : "Unable to import items",
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
    <Dialog open={open} onOpenChange={(v) => (v ? onOpenChange(true) : handleClose())}>
      <DialogContent className="max-w-3xl">
        <DialogHeader>
          <DialogTitle>Bulk import items</DialogTitle>
          <DialogDescription>
            Upload a CSV or Excel (.xlsx) file with up to {MAX_ROWS} rows.
            Required columns are{" "}
            <code className="font-mono">SKU</code> and{" "}
            <code className="font-mono">Name</code>.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-4">
          {/* File chooser + template */}
          <div className="flex flex-wrap items-center gap-3">
            <input
              ref={fileInputRef}
              type="file"
              accept=".csv,.xlsx,.xls,text/csv,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
              className="hidden"
              data-testid="input-bulk-import-file"
              onChange={(e) => {
                const file = e.target.files?.[0];
                if (file) handleFile(file);
              }}
            />
            <Button
              type="button"
              variant="outline"
              onClick={() => fileInputRef.current?.click()}
              disabled={parsing || validating || committing}
              data-testid="btn-bulk-import-choose-file"
            >
              <Upload className="mr-2 h-4 w-4" />
              {hasFile ? "Choose another file" : "Choose CSV or Excel file"}
            </Button>
            <Button
              type="button"
              variant="ghost"
              onClick={downloadTemplate}
              data-testid="btn-bulk-import-template"
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

          {/* Mode picker */}
          {hasFile && (
            <div className="rounded-md border bg-muted/30 p-3">
              <Label className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">
                When a SKU already exists
              </Label>
              <RadioGroup
                value={mode}
                onValueChange={(v) => handleModeChange(v as Mode)}
                className="mt-2 flex flex-col gap-1.5"
              >
                <label className="flex items-start gap-2 cursor-pointer">
                  <RadioGroupItem value="create" id="bulk-mode-create" className="mt-1" />
                  <div className="text-sm">
                    <div className="font-medium">Skip and report errors</div>
                    <div className="text-xs text-muted-foreground">
                      Rows whose SKU already exists are flagged as errors. The import is rejected unless every row is new.
                    </div>
                  </div>
                </label>
                <label className="flex items-start gap-2 cursor-pointer">
                  <RadioGroupItem value="upsert" id="bulk-mode-upsert" className="mt-1" />
                  <div className="text-sm">
                    <div className="font-medium">Update existing items</div>
                    <div className="text-xs text-muted-foreground">
                      Existing simple items are updated by SKU. Variants, bundles and batch-tracked items are still rejected — edit those individually.
                    </div>
                  </div>
                </label>
              </RadioGroup>
            </div>
          )}

          {/* Warnings & errors */}
          {warnings.length > 0 && (
            <Alert>
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>
                {warnings.map((w, i) => (
                  <div key={i}>{w}</div>
                ))}
              </AlertDescription>
            </Alert>
          )}
          {topLevelError && (
            <Alert variant="destructive">
              <AlertCircle className="h-4 w-4" />
              <AlertDescription>{topLevelError}</AlertDescription>
            </Alert>
          )}

          {/* Counts summary */}
          {counts && (
            <div className="flex flex-wrap items-center gap-2 text-sm">
              <Badge variant="secondary" className="gap-1">
                <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
                {counts.create} to create
              </Badge>
              <Badge variant="secondary" className="gap-1">
                <CheckCircle2 className="h-3.5 w-3.5 text-blue-600" />
                {counts.update} to update
              </Badge>
              {counts.error > 0 && (
                <Badge variant="destructive" className="gap-1">
                  <AlertCircle className="h-3.5 w-3.5" />
                  {counts.error} error{counts.error > 1 ? "s" : ""}
                </Badge>
              )}
              {validating && (
                <span className="flex items-center gap-1.5 text-xs text-muted-foreground">
                  <Loader2 className="h-3.5 w-3.5 animate-spin" />
                  Validating…
                </span>
              )}
            </div>
          )}

          {/* Preview table */}
          {hasFile && results && (
            <div className="rounded-md border overflow-hidden">
              <ScrollArea className="h-[280px]">
                <div className="overflow-x-auto">
                  <table className="w-max min-w-full text-sm">
                    <thead className="bg-muted/50 sticky top-0">
                      <tr className="text-left text-xs uppercase tracking-wide text-muted-foreground">
                        <th className="px-3 py-2 w-10">#</th>
                        <th className="px-3 py-2 w-20">Status</th>
                        <th className="px-3 py-2">SKU</th>
                        <th className="px-3 py-2">Name</th>
                        <th className="px-3 py-2">Description</th>
                        <th className="px-3 py-2">Category</th>
                        <th className="px-3 py-2">Unit</th>
                        <th className="px-3 py-2">Sale Price</th>
                        <th className="px-3 py-2">MRP</th>
                        <th className="px-3 py-2">Tax %</th>
                        <th className="px-3 py-2">HSN</th>
                        <th className="px-3 py-2">Barcode</th>
                        <th className="px-3 py-2">Min Stock</th>
                        <th className="px-3 py-2">Max Disc %</th>
                        <th className="px-3 py-2">Max Disc ₹</th>
                        <th className="px-3 py-2">Total Stock</th>
                        <th className="px-3 py-2">Error</th>
                      </tr>
                    </thead>
                    <tbody>
                      {results.map((r) => {
                        const row = rows[r.index - 1];
                        return (
                          <tr
                            key={r.index}
                            className={cn(
                              "border-t",
                              r.action === "error" && "bg-destructive/5",
                            )}
                          >
                            <td className="px-3 py-2 text-muted-foreground text-xs">
                              {r.index}
                            </td>
                            <td className="px-3 py-2">
                              <Badge
                                variant={
                                  r.action === "error"
                                    ? "destructive"
                                    : r.action === "update"
                                      ? "secondary"
                                      : "default"
                                }
                                className="text-[10px] capitalize"
                              >
                                {r.action}
                              </Badge>
                            </td>
                            <td className="px-3 py-2 font-mono text-xs whitespace-nowrap">
                              {r.sku || row?.sku || ""}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap max-w-[140px] truncate">
                              {row?.name || ""}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap max-w-[120px] truncate text-xs text-muted-foreground">
                              {row?.description || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-muted-foreground">
                              {row?.category || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-muted-foreground">
                              {row?.unit || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-right">
                              {row?.salePrice || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-right">
                              {row?.purchasePrice || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-right">
                              {row?.taxRate || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-muted-foreground">
                              {row?.hsnCode || "—"}
                            </td>
                            <td className="px-3 py-2 font-mono text-xs whitespace-nowrap text-muted-foreground">
                              {row?.barcode || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-right">
                              {row?.reorderLevel || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-right">
                              {row?.maxDiscountPercent || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-right">
                              {row?.maxDiscountAmount || "—"}
                            </td>
                            <td className="px-3 py-2 whitespace-nowrap text-xs text-right font-medium">
                              {row?.totalStock || "—"}
                            </td>
                            <td className="px-3 py-2 text-xs text-destructive whitespace-nowrap">
                              {r.error ?? ""}
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                </div>
              </ScrollArea>
            </div>
          )}
        </div>

        <DialogFooter>
          <Button
            type="button"
            variant="ghost"
            onClick={handleClose}
            disabled={committing}
            data-testid="btn-bulk-import-cancel"
          >
            Cancel
          </Button>
          <Button
            type="button"
            onClick={handleCommit}
            disabled={!canCommit}
            data-testid="btn-bulk-import-commit"
          >
            {committing ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Importing…
              </>
            ) : (
              `Import ${
                counts ? counts.create + counts.update : rows.length
              } items`
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
