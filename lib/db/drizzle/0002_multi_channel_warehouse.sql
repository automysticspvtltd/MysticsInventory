-- Allow multiple warehouses per sales channel (drop single-warehouse unique, add per-row unique)
DROP INDEX IF EXISTS "sales_channel_defaults_org_channel_idx";
CREATE UNIQUE INDEX IF NOT EXISTS "sales_channel_defaults_org_channel_wh_idx" ON "sales_channel_warehouse_defaults" ("organization_id","sales_channel","warehouse_id");
