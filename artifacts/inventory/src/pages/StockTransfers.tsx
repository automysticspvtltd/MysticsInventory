import { Link } from "wouter";
import { useEffect, useState } from "react";
import { PageHeader } from "@/components/PageHeader";
import {
  useListStockTransfers,
  useListWarehouses,
} from "@/lib/queryKeys";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { formatDate } from "@/lib/format";
import { Plus, ArrowRight, ChevronLeft, ChevronRight, Upload } from "lucide-react";
import { StatusBadge } from "@/components/StatusBadge";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { ReportExportButton, type ExportColumn } from "@/components/ReportExportButton";
import { BulkImportStockTransferDialog } from "@/components/BulkImportStockTransferDialog";
import type { StockTransfer } from "@workspace/api-client-react";

const ITEMS_PER_PAGE = 15;

const EXPORT_COLUMNS: ExportColumn<StockTransfer>[] = [
  { header: "Transfer #", accessor: (r) => r.transferNumber },
  { header: "Date", accessor: (r) => r.transferDate },
  { header: "From Warehouse", accessor: (r) => r.fromWarehouseName },
  { header: "To Warehouse", accessor: (r) => r.toWarehouseName },
  { header: "Status", accessor: (r) => r.status },
  { header: "Notes", accessor: (r) => r.notes ?? "" },
];

export default function StockTransfers() {
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [warehouseFilter, setWarehouseFilter] = useState<string>("all");
  const [fromDate, setFromDate] = useState<string>("");
  const [toDate, setToDate] = useState<string>("");
  const [page, setPage] = useState(1);
  const [importOpen, setImportOpen] = useState(false);

  useEffect(() => setPage(1), [statusFilter, warehouseFilter, fromDate, toDate]);

  const { data: warehouses } = useListWarehouses();
  const { data: transfers, isLoading } = useListStockTransfers({
    status: statusFilter === "all" ? undefined : statusFilter,
    warehouseId:
      warehouseFilter === "all" ? undefined : Number(warehouseFilter),
    fromDate: fromDate || undefined,
    toDate: toDate || undefined,
  });

  const hasDateFilter = fromDate !== "" || toDate !== "";

  return (
    <div className="space-y-6">
      <PageHeader
        title="Stock Transfers"
        description="Move inventory between your warehouses."
        actions={
          <div className="flex items-center gap-2">
            <ReportExportButton
              filename="stock-transfers"
              title="Stock Transfers"
              columns={EXPORT_COLUMNS}
              rows={transfers ?? []}
              hidePdf
            />
            <Button
              variant="outline"
              size="sm"
              onClick={() => setImportOpen(true)}
              data-testid="btn-import-transfers"
            >
              <Upload className="h-4 w-4 mr-2" />
              Import
            </Button>
            <Button asChild data-testid="btn-create-transfer">
              <Link href="/transfers/new">
                <Plus className="mr-2 h-4 w-4" />
                New Transfer
              </Link>
            </Button>
          </div>
        }
      />

      <div className="flex flex-col sm:flex-row sm:items-end gap-4 bg-card border rounded-lg p-4">
        <div className="space-y-1 w-full sm:w-56">
          <Label>Status</Label>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger data-testid="filter-transfer-status">
              <SelectValue placeholder="All Statuses" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Statuses</SelectItem>
              <SelectItem value="draft">Draft</SelectItem>
              <SelectItem value="in_transit">In transit</SelectItem>
              <SelectItem value="completed">Completed</SelectItem>
              <SelectItem value="cancelled">Cancelled</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1 w-full sm:w-64">
          <Label>Warehouse (source or destination)</Label>
          <Select
            value={warehouseFilter}
            onValueChange={setWarehouseFilter}
          >
            <SelectTrigger data-testid="filter-transfer-warehouse">
              <SelectValue placeholder="All Warehouses" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Warehouses</SelectItem>
              {warehouses?.map((w) => (
                <SelectItem key={w.id} value={w.id.toString()}>
                  {w.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        <div className="space-y-1 w-full sm:w-44">
          <Label>From date</Label>
          <Input
            type="date"
            value={fromDate}
            onChange={(e) => setFromDate(e.target.value)}
            data-testid="filter-transfer-from-date"
          />
        </div>
        <div className="space-y-1 w-full sm:w-44">
          <Label>To date</Label>
          <Input
            type="date"
            value={toDate}
            onChange={(e) => setToDate(e.target.value)}
            data-testid="filter-transfer-to-date"
          />
        </div>
        {hasDateFilter && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => {
              setFromDate("");
              setToDate("");
            }}
            data-testid="btn-clear-transfer-dates"
          >
            Clear dates
          </Button>
        )}
      </div>

      <div className="rounded-md border bg-card">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Transfer #</TableHead>
              <TableHead>Date</TableHead>
              <TableHead>From</TableHead>
              <TableHead></TableHead>
              <TableHead>To</TableHead>
              <TableHead>Status</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              <TableRow>
                <TableCell colSpan={6} className="h-24 text-center">
                  Loading...
                </TableCell>
              </TableRow>
            ) : transfers?.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} className="h-24 text-center">
                  No transfers found.
                </TableCell>
              </TableRow>
            ) : (
              (transfers ?? []).slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE).map((tr) => (
                <TableRow key={tr.id} data-testid={`row-transfer-${tr.id}`}>
                  <TableCell className="font-mono">
                    <Link
                      href={`/transfers/${tr.id}`}
                      className="font-medium text-primary hover:underline"
                    >
                      {tr.transferNumber}
                    </Link>
                  </TableCell>
                  <TableCell>{formatDate(tr.transferDate)}</TableCell>
                  <TableCell>{tr.fromWarehouseName}</TableCell>
                  <TableCell className="text-muted-foreground">
                    <ArrowRight className="h-4 w-4" />
                  </TableCell>
                  <TableCell>{tr.toWarehouseName}</TableCell>
                  <TableCell>
                    <StatusBadge status={tr.status} />
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {(transfers?.length ?? 0) > 0 && (
        <div className="flex items-center justify-between px-1">
          <p className="text-sm text-muted-foreground">
            Showing {Math.min((page - 1) * ITEMS_PER_PAGE + 1, transfers!.length)}–{Math.min(page * ITEMS_PER_PAGE, transfers!.length)} of {transfers!.length}
          </p>
          <div className="flex items-center gap-1">
            <Button variant="outline" size="icon" className="h-8 w-8" disabled={page <= 1} onClick={() => setPage(p => Math.max(1, p - 1))} aria-label="Previous page">
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <span className="text-sm px-2">{page} / {Math.max(1, Math.ceil(transfers!.length / ITEMS_PER_PAGE))}</span>
            <Button variant="outline" size="icon" className="h-8 w-8" disabled={page >= Math.ceil(transfers!.length / ITEMS_PER_PAGE)} onClick={() => setPage(p => Math.min(Math.ceil(transfers!.length / ITEMS_PER_PAGE), p + 1))} aria-label="Next page">
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      )}

      <BulkImportStockTransferDialog
        open={importOpen}
        onOpenChange={setImportOpen}
      />
    </div>
  );
}
