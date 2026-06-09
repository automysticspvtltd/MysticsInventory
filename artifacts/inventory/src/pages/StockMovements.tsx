import { useEffect, useState } from "react";
import { PageHeader } from "@/components/PageHeader";
import { useListStockMovements, useListItems, useListWarehouses } from "@/lib/queryKeys";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { format } from "date-fns";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { ChevronLeft, ChevronRight } from "lucide-react";

const ITEMS_PER_PAGE = 15;

export default function StockMovements() {
  const [itemId, setItemId] = useState<number | undefined>();
  const [warehouseId, setWarehouseId] = useState<number | undefined>();
  const [page, setPage] = useState(1);

  useEffect(() => setPage(1), [itemId, warehouseId]);

  const { data: movements, isLoading } = useListStockMovements({
    itemId: itemId || undefined,
    warehouseId: warehouseId || undefined,
  });

  const { data: items } = useListItems({ leafOnly: true });
  const { data: warehouses } = useListWarehouses();

  return (
    <div className="space-y-6">
      <PageHeader 
        title="Stock Movements" 
        description="View the ledger of all inventory additions and deductions."
      />

      <div className="flex flex-col sm:flex-row items-end sm:items-center gap-4 bg-card border rounded-lg p-4">
        <div className="w-full sm:w-64 space-y-1">
          <Label>Filter by Item</Label>
          <Select 
            value={itemId ? itemId.toString() : "all"} 
            onValueChange={(val) => setItemId(val === "all" ? undefined : parseInt(val))}
          >
            <SelectTrigger data-testid="filter-item">
              <SelectValue placeholder="All Items" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Items</SelectItem>
              {items?.map(i => {
                const variantSuffix = (() => {
                  if (!i.parentItemId || !i.variantOptions) return "";
                  const opts = i.variantOptions as Record<string, unknown>;
                  const label = Object.entries(opts)
                    .filter(([k]) => k !== "axes")
                    .map(([, v]) => (typeof v === "string" ? v : ""))
                    .filter(Boolean)
                    .join(" / ");
                  return label ? ` (${label})` : "";
                })();
                return (
                  <SelectItem key={i.id} value={i.id.toString()}>
                    {i.name}{variantSuffix}
                  </SelectItem>
                );
              })}
            </SelectContent>
          </Select>
        </div>
        <div className="w-full sm:w-64 space-y-1">
          <Label>Filter by Warehouse</Label>
          <Select 
            value={warehouseId ? warehouseId.toString() : "all"} 
            onValueChange={(val) => setWarehouseId(val === "all" ? undefined : parseInt(val))}
          >
            <SelectTrigger data-testid="filter-warehouse">
              <SelectValue placeholder="All Warehouses" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Warehouses</SelectItem>
              {warehouses?.map(w => (
                <SelectItem key={w.id} value={w.id.toString()}>{w.name}</SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </div>

      <div className="rounded-md border bg-card">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Date</TableHead>
              <TableHead>SKU</TableHead>
              <TableHead>Barcode</TableHead>
              <TableHead>Category</TableHead>
              <TableHead>Item</TableHead>
              <TableHead className="text-right">Quantity</TableHead>
              <TableHead>Warehouse</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading ? (
              <TableRow>
                <TableCell colSpan={7} className="h-24 text-center">Loading...</TableCell>
              </TableRow>
            ) : movements?.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} className="h-24 text-center">No movements found.</TableCell>
              </TableRow>
            ) : (
              (movements ?? []).slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE).map((movement) => (
                <TableRow key={movement.id} data-testid={`row-movement-${movement.id}`}>
                  <TableCell className="text-muted-foreground whitespace-nowrap">
                    {format(new Date(movement.createdAt), "MMM d, yyyy h:mm a")}
                  </TableCell>
                  <TableCell className="font-mono text-xs">{movement.itemSku ?? "-"}</TableCell>
                  <TableCell className="font-mono text-xs text-muted-foreground">{movement.itemBarcode ?? "-"}</TableCell>
                  <TableCell className="text-muted-foreground">{movement.itemCategory ?? "-"}</TableCell>
                  <TableCell className="font-medium">{movement.itemName}</TableCell>
                  <TableCell className="text-right font-medium">
                    <span className={movement.quantity > 0 ? "text-green-600" : "text-destructive"}>
                      {movement.quantity > 0 ? "+" : ""}{movement.quantity}
                    </span>
                  </TableCell>
                  <TableCell>{movement.warehouseName}</TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </div>

      {(movements?.length ?? 0) > 0 && (
        <div className="flex items-center justify-between px-1">
          <p className="text-sm text-muted-foreground">
            Showing {Math.min((page - 1) * ITEMS_PER_PAGE + 1, movements!.length)}–{Math.min(page * ITEMS_PER_PAGE, movements!.length)} of {movements!.length}
          </p>
          <div className="flex items-center gap-1">
            <Button variant="outline" size="icon" className="h-8 w-8" disabled={page <= 1} onClick={() => setPage(p => Math.max(1, p - 1))} aria-label="Previous page">
              <ChevronLeft className="h-4 w-4" />
            </Button>
            <span className="text-sm px-2">{page} / {Math.max(1, Math.ceil(movements!.length / ITEMS_PER_PAGE))}</span>
            <Button variant="outline" size="icon" className="h-8 w-8" disabled={page >= Math.ceil(movements!.length / ITEMS_PER_PAGE)} onClick={() => setPage(p => Math.min(Math.ceil(movements!.length / ITEMS_PER_PAGE), p + 1))} aria-label="Next page">
              <ChevronRight className="h-4 w-4" />
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
