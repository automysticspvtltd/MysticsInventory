CREATE TABLE "shopify_import_jobs" (
	"id" varchar PRIMARY KEY NOT NULL,
	"organization_id" integer NOT NULL,
	"status" text NOT NULL,
	"total" integer,
	"processed" integer DEFAULT 0 NOT NULL,
	"imported" integer DEFAULT 0 NOT NULL,
	"skipped" integer DEFAULT 0 NOT NULL,
	"failed" integer DEFAULT 0 NOT NULL,
	"failed_orders" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"from_date" text,
	"to_date" text,
	"error" text,
	"started_at" timestamp with time zone DEFAULT now() NOT NULL,
	"finished_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "print_log" (
	"id" serial PRIMARY KEY NOT NULL,
	"organization_id" integer NOT NULL,
	"user_id" integer NOT NULL,
	"document_type" text NOT NULL,
	"document_id" integer,
	"printed_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sales_channel_warehouse_defaults" (
	"id" serial PRIMARY KEY NOT NULL,
	"organization_id" integer NOT NULL,
	"sales_channel" text NOT NULL,
	"warehouse_id" integer NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "username" text;--> statement-breakpoint
ALTER TABLE "organizations" ADD COLUMN "login_logo_url" text;--> statement-breakpoint
ALTER TABLE "organizations" ADD COLUMN "sidebar_logo_url" text;--> statement-breakpoint
ALTER TABLE "organizations" ADD COLUMN "thermal_logo_url" text;--> statement-breakpoint
ALTER TABLE "organizations" ADD COLUMN "max_order_discount_percent" numeric(5, 2);--> statement-breakpoint
ALTER TABLE "organizations" ADD COLUMN "max_order_discount_amount" numeric(12, 2);--> statement-breakpoint
ALTER TABLE "organization_members" ADD COLUMN "can_edit_bills" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "organization_members" ADD COLUMN "can_edit_stocks" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "items" ADD COLUMN "max_discount_percent" numeric(5, 2);--> statement-breakpoint
ALTER TABLE "items" ADD COLUMN "max_discount_amount" numeric(12, 2);--> statement-breakpoint
ALTER TABLE "shopify_import_jobs" ADD CONSTRAINT "shopify_import_jobs_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "print_log" ADD CONSTRAINT "print_log_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "print_log" ADD CONSTRAINT "print_log_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_channel_warehouse_defaults" ADD CONSTRAINT "sales_channel_warehouse_defaults_organization_id_organizations_id_fk" FOREIGN KEY ("organization_id") REFERENCES "public"."organizations"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sales_channel_warehouse_defaults" ADD CONSTRAINT "sales_channel_warehouse_defaults_warehouse_id_warehouses_id_fk" FOREIGN KEY ("warehouse_id") REFERENCES "public"."warehouses"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "shopify_import_jobs_org_idx" ON "shopify_import_jobs" USING btree ("organization_id");--> statement-breakpoint
CREATE INDEX "shopify_import_jobs_finished_at_idx" ON "shopify_import_jobs" USING btree ("finished_at");--> statement-breakpoint
CREATE UNIQUE INDEX "sales_channel_defaults_org_channel_wh_idx" ON "sales_channel_warehouse_defaults" USING btree ("organization_id","sales_channel","warehouse_id");--> statement-breakpoint
CREATE UNIQUE INDEX "users_username_idx" ON "users" USING btree ("username");