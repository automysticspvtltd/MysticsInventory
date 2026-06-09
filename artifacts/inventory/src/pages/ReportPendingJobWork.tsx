import { useState } from "react";
import { Link } from "wouter";
import { PageHeader } from "@/components/PageHeader";
import { useReportPendingJobWork } from "@/lib/queryKeys";
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
import { StatusBadge } from "@/components/StatusBadge";
import { ArrowLeft, ChevronLeft, ChevronRight } from "lucide-react";
import { formatDate } from "@/lib/format";

export default function ReportPendingJobWork() {
  const { data, isLoading } = useReportPendingJobWork();
  const rows = data?.rows ?? [];

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const ITEMS_PER_PAGE = 15;
  const [page, setPage] = useState(1);
  const total = rows.length;
  const pagedRows = rows.slice((page - 1) * ITEMS_PER_PAGE, page * ITEMS_PER_PAGE);

  return (
    <div className="space-y-6">
      <PageHeader
        title="Pending Job Work"
        description="Job work orders awaiting receipt of finished goods, with how much is still outstanding."
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
      ) : rows.length === 0 ? (
        <Card>
          <CardContent className="py-12 text-center text-muted-foreground">
            No job work orders are currently pending.
          </CardContent>
        </Card>
      ) : (
        <Card>
          <CardContent className="pt-6">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>JWO #</TableHead>
                  <TableHead>Job worker</TableHead>
                  <TableHead>Output</TableHead>
                  <TableHead className="text-right">Ordered</TableHead>
                  <TableHead className="text-right">Received</TableHead>
                  <TableHead className="text-right">Scrapped</TableHead>
                  <TableHead className="text-right">Remaining</TableHead>
                  <TableHead className="text-right">At worker</TableHead>
                  <TableHead>Expected</TableHead>
                  <TableHead>Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {pagedRows.map((row) => {
                  const expected = row.expectedReturnDate
                    ? new Date(row.expectedReturnDate)
                    : null;
                  const overdue = expected ? expected < today : false;
                  return (
                    <TableRow
                      key={row.jobWorkOrderId}
                      data-testid={`row-pending-${row.jobWorkOrderId}`}
                    >
                      <TableCell className="font-mono text-xs">
                        <Link
                          href={`/job-work/${row.jobWorkOrderId}`}
                          className="hover:underline"
                        >
                          {row.jwoNumber}
                        </Link>
                      </TableCell>
                      <TableCell>
                        <Link
                          href={`/suppliers/${row.supplierId}`}
                          className="hover:underline"
                        >
                          {row.supplierName}
                        </Link>
                      </TableCell>
                      <TableCell>
                        <div>{row.outputItemName}</div>
                        <div className="font-mono text-xs text-muted-foreground">
                          {row.outputItemSku}
                        </div>
                      </TableCell>
                      <TableCell className="text-right">
                        {Number(row.orderedQuantity)}
                      </TableCell>
                      <TableCell className="text-right">
                        {Number(row.receivedQuantity)}
                      </TableCell>
                      <TableCell className="text-right text-muted-foreground">
                        {Number(row.scrappedQuantity)}
                      </TableCell>
                      <TableCell className="text-right font-medium">
                        {Number(row.remainingQuantity)}
                      </TableCell>
                      <TableCell
                        className="text-right text-muted-foreground"
                        title="Component units still physically held by the worker (issued minus consumed and scrapped on receipts)"
                        data-testid={`cell-at-worker-${row.jobWorkOrderId}`}
                      >
                        {Number(row.componentsAtVendorTotal)}
                      </TableCell>
                      <TableCell
                        className={
                          overdue
                            ? "text-destructive font-medium"
                            : "text-muted-foreground"
                        }
                      >
                        {row.expectedReturnDate
                          ? formatDate(row.expectedReturnDate)
                          : "—"}
                      </TableCell>
                      <TableCell>
                        <StatusBadge status={row.status} />
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
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
          </CardContent>
        </Card>
      )}
    </div>
  );
}
