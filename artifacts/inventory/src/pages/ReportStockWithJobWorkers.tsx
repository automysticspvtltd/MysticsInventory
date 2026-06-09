import { useState } from "react";
import { Link } from "wouter";
import { PageHeader } from "@/components/PageHeader";
import { useReportStockWithJobWorkers } from "@/lib/queryKeys";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { ArrowLeft, ChevronLeft, ChevronRight } from "lucide-react";

export default function ReportStockWithJobWorkers() {
  const { data, isLoading } = useReportStockWithJobWorkers();
  const rows = data?.rows ?? [];

  // Group rows by supplier for easier scanning.
  const grouped = rows.reduce<
    Record<
      number,
      { supplierName: string; items: typeof rows }
    >
  >((acc, row) => {
    if (!acc[row.supplierId]) {
      acc[row.supplierId] = {
        supplierName: row.supplierName,
        items: [],
      };
    }
    acc[row.supplierId].items.push(row);
    return acc;
  }, {});
  const groupedList = Object.entries(grouped).map(([id, g]) => ({
    supplierId: Number(id),
    supplierName: g.supplierName,
    items: g.items,
  }));

  const ITEMS_PER_PAGE = 10;
  const [page, setPage] = useState(1);
  const totalGroups = groupedList.length;
  const pagedGroupedList = groupedList.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Stock with Job Workers"
        description="Materials currently sitting at outside job workers, by worker."
        actions={
          <Button variant="outline" asChild>
            <Link href="/reports">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back to reports
            </Link>
          </Button>
        }
      />

      {isLoading ? (
        <Card>
          <CardContent className="py-12 text-center text-muted-foreground">
            Loading...
          </CardContent>
        </Card>
      ) : groupedList.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center text-muted-foreground">
            No stock is currently held at any job worker.
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {pagedGroupedList.map((group) => (
            <Card
              key={group.supplierId}
              data-testid={`group-${group.supplierId}`}
            >
              <CardContent className="pt-6">
                <div className="flex items-center justify-between mb-3">
                  <Link
                    href={`/suppliers/${group.supplierId}`}
                    className="text-base font-semibold text-primary hover:underline"
                  >
                    {group.supplierName}
                  </Link>
                  <span className="text-xs text-muted-foreground">
                    {group.items.length} item
                    {group.items.length === 1 ? "" : "s"}
                  </span>
                </div>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Item</TableHead>
                      <TableHead>SKU</TableHead>
                      <TableHead className="text-right">Quantity</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {group.items.map((row) => (
                      <TableRow
                        key={`${row.warehouseId}-${row.itemId}`}
                        data-testid={`row-${row.warehouseId}-${row.itemId}`}
                      >
                        <TableCell>
                          <Link
                            href={`/items/${row.itemId}`}
                            className="hover:underline"
                          >
                            {row.itemName}
                          </Link>
                        </TableCell>
                        <TableCell className="font-mono text-xs">
                          {row.sku}
                        </TableCell>
                        <TableCell className="text-right font-medium">
                          {Number(row.quantity)}
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </CardContent>
            </Card>
          ))}
          {totalGroups > ITEMS_PER_PAGE && (
            <div className="flex items-center justify-between px-2 py-3 border rounded-md bg-card">
              <p className="text-sm text-muted-foreground">
                Showing {(page - 1) * ITEMS_PER_PAGE + 1}–{Math.min(page * ITEMS_PER_PAGE, totalGroups)} of {totalGroups} workers
              </p>
              <div className="flex items-center gap-1">
                <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setPage(p => p - 1)} disabled={page === 1}>
                  <ChevronLeft className="h-4 w-4" />
                </Button>
                <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setPage(p => p + 1)} disabled={page * ITEMS_PER_PAGE >= totalGroups}>
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </div>
          )}
        </div>
      )}
    </div>
  );
}
