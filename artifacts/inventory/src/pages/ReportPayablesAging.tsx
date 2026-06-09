import { useState } from "react";
import { Link } from "wouter";
import { PageHeader } from "@/components/PageHeader";
import {
  useGetPayablesAgingReport,
  getGetPayablesAgingReportQueryKey,
} from "@/lib/queryKeys";
import { Card, CardContent } from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableFooter,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from "@/components/ui/button";
import { ArrowLeft, ChevronLeft, ChevronRight } from "lucide-react";
import { formatCurrency } from "@/lib/format";
import { ReportExportButton, type ExportColumn } from "@/components/ReportExportButton";

export default function ReportPayablesAging() {
  const { data, isLoading } = useGetPayablesAgingReport({
    query: { queryKey: getGetPayablesAgingReportQueryKey() },
  });

  const ITEMS_PER_PAGE = 15;
  const [page, setPage] = useState(1);
  const total = data?.rows.length ?? 0;
  const pagedRows = (data?.rows ?? []).slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE);

  type Row = NonNullable<typeof data>["rows"][number];
  const exportColumns: ExportColumn<Row>[] = [
    { header: "Supplier", accessor: (r) => r.supplierName },
    { header: "Current", accessor: (r) => r.current },
    { header: "1-30", accessor: (r) => r.b30 },
    { header: "31-60", accessor: (r) => r.b60 },
    { header: "61-90", accessor: (r) => r.b90 },
    { header: "90+", accessor: (r) => r.b90plus },
    { header: "Total", accessor: (r) => r.total },
  ];

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-4">
        <Button variant="ghost" size="icon" asChild>
          <Link href="/reports">
            <ArrowLeft className="h-5 w-5" />
          </Link>
        </Button>
        <PageHeader
          title="Payables Aging"
          description="Outstanding supplier balances bucketed by age."
          className="mb-0"
        />
        <div className="ml-auto">
          <ReportExportButton
            filename="payables-aging"
            title="Payables Aging"
            columns={exportColumns}
            rows={data?.rows ?? []}
            disabled={isLoading}
            meta={
              data
                ? [{ label: "Grand Total Outstanding", value: formatCurrency(data.totals.total) }]
                : []
            }
          />
        </div>
      </div>

      <Card>
        <CardContent className="pt-6">
          {isLoading || !data ? (
            <Skeleton className="h-40 w-full" />
          ) : data.rows.length === 0 ? (
            <p className="text-sm text-muted-foreground">
              No outstanding payables. Everything is current.
            </p>
          ) : (
            <>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Supplier</TableHead>
                  <TableHead className="text-right">Current</TableHead>
                  <TableHead className="text-right">1-30</TableHead>
                  <TableHead className="text-right">31-60</TableHead>
                  <TableHead className="text-right">61-90</TableHead>
                  <TableHead className="text-right">90+</TableHead>
                  <TableHead className="text-right">Total</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {pagedRows.map((r) => (
                  <TableRow
                    key={r.supplierId}
                    data-testid={`row-payables-aging-${r.supplierId}`}
                  >
                    <TableCell className="font-medium">
                      <Link
                        href={`/supplier-payments?supplierId=${r.supplierId}`}
                        className="text-primary hover:underline"
                      >
                        {r.supplierName}
                      </Link>
                    </TableCell>
                    <TableCell className="text-right">
                      {formatCurrency(r.current)}
                    </TableCell>
                    <TableCell className="text-right">
                      {formatCurrency(r.b30)}
                    </TableCell>
                    <TableCell className="text-right">
                      {formatCurrency(r.b60)}
                    </TableCell>
                    <TableCell className="text-right">
                      {formatCurrency(r.b90)}
                    </TableCell>
                    <TableCell className="text-right text-orange-600">
                      {formatCurrency(r.b90plus)}
                    </TableCell>
                    <TableCell className="text-right font-semibold">
                      {formatCurrency(r.total)}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
              <TableFooter>
                <TableRow>
                  <TableCell className="font-semibold">Totals</TableCell>
                  <TableCell className="text-right font-semibold">
                    {formatCurrency(data.totals.current)}
                  </TableCell>
                  <TableCell className="text-right font-semibold">
                    {formatCurrency(data.totals.b30)}
                  </TableCell>
                  <TableCell className="text-right font-semibold">
                    {formatCurrency(data.totals.b60)}
                  </TableCell>
                  <TableCell className="text-right font-semibold">
                    {formatCurrency(data.totals.b90)}
                  </TableCell>
                  <TableCell className="text-right font-semibold">
                    {formatCurrency(data.totals.b90plus)}
                  </TableCell>
                  <TableCell className="text-right font-bold">
                    {formatCurrency(data.totals.total)}
                  </TableCell>
                </TableRow>
              </TableFooter>
            </Table>
            {total > ITEMS_PER_PAGE && (
              <div className="flex items-center justify-between px-2 py-3 border-t mt-2">
                <p className="text-sm text-muted-foreground">
                  Showing {(page - 1) * ITEMS_PER_PAGE + 1}–{Math.min(page * ITEMS_PER_PAGE, total)} of {total}
                </p>
                <div className="flex items-center gap-1">
                  <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setPage(p => p - 1)} disabled={page === 1}>
                    <ChevronLeft className="h-4 w-4" />
                  </Button>
                  <Button variant="outline" size="icon" className="h-8 w-8" onClick={() => setPage(p => p + 1)} disabled={page * ITEMS_PER_PAGE >= total}>
                    <ChevronRight className="h-4 w-4" />
                  </Button>
                </div>
              </div>
            )}
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
