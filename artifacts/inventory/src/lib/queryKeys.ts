export * from "@workspace/api-client-react";

export async function bulkMoveWarehouse(payload: {
  ids: number[];
  warehouseId: number;
}): Promise<{ moved: number }> {
  const res = await fetch("/api/items/bulk-move-warehouse", {
    method: "PATCH",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    const err: unknown = await res.json().catch(() => ({}));
    throw new Error(
      (err as { error?: string }).error ?? "Move warehouse failed",
    );
  }
  return res.json() as Promise<{ moved: number }>;
}
