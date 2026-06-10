--
-- PostgreSQL database dump
--

\restrict jHdHSxXu8PAQNtnDz9CF3Cu3EwUaHNSDkSirqSsKtP4B9egEU0yhSGchcVZuppj

-- Dumped from database version 16.10
-- Dumped by pg_dump version 16.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: customer_payment_allocations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_payment_allocations (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    payment_id integer NOT NULL,
    sales_order_id integer NOT NULL,
    amount numeric(14,2) NOT NULL
);


ALTER TABLE public.customer_payment_allocations OWNER TO postgres;

--
-- Name: customer_payment_allocations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_payment_allocations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_payment_allocations_id_seq OWNER TO postgres;

--
-- Name: customer_payment_allocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_payment_allocations_id_seq OWNED BY public.customer_payment_allocations.id;


--
-- Name: customer_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_payments (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    customer_id integer NOT NULL,
    payment_date date NOT NULL,
    amount numeric(14,2) NOT NULL,
    mode text NOT NULL,
    reference_number text,
    notes text,
    bank_account_label text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.customer_payments OWNER TO postgres;

--
-- Name: customer_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_payments_id_seq OWNER TO postgres;

--
-- Name: customer_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_payments_id_seq OWNED BY public.customer_payments.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    name text NOT NULL,
    email text,
    phone text,
    company text,
    gst_number text,
    billing_address text,
    shipping_address text,
    place_of_supply text,
    notes text,
    outstanding_balance numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: einvoice_bulk_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.einvoice_bulk_batches (
    id character varying NOT NULL,
    organization_id integer NOT NULL,
    status text NOT NULL,
    total integer DEFAULT 0 NOT NULL,
    processed integer DEFAULT 0 NOT NULL,
    succeeded integer DEFAULT 0 NOT NULL,
    failed integer DEFAULT 0 NOT NULL,
    skipped integer DEFAULT 0 NOT NULL,
    order_ids_in_order jsonb DEFAULT '[]'::jsonb NOT NULL,
    results jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    concurrency integer DEFAULT 1 NOT NULL,
    recovery_claimed_at timestamp with time zone
);


ALTER TABLE public.einvoice_bulk_batches OWNER TO postgres;

--
-- Name: email_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_log (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    sales_order_id integer,
    kind text NOT NULL,
    recipient text NOT NULL,
    subject text NOT NULL,
    status text NOT NULL,
    error_message text,
    sent_by_user_id integer,
    sent_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.email_log OWNER TO postgres;

--
-- Name: email_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.email_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.email_log_id_seq OWNER TO postgres;

--
-- Name: email_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.email_log_id_seq OWNED BY public.email_log.id;


--
-- Name: email_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_settings (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    host text NOT NULL,
    port integer NOT NULL,
    secure text DEFAULT 'starttls'::text NOT NULL,
    username text NOT NULL,
    password_encrypted text NOT NULL,
    from_email text NOT NULL,
    from_name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.email_settings OWNER TO postgres;

--
-- Name: email_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.email_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.email_settings_id_seq OWNER TO postgres;

--
-- Name: email_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.email_settings_id_seq OWNED BY public.email_settings.id;


--
-- Name: goods_receipt_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.goods_receipt_lines (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    goods_receipt_id integer NOT NULL,
    purchase_order_line_id integer NOT NULL,
    quantity numeric(14,2) NOT NULL
);


ALTER TABLE public.goods_receipt_lines OWNER TO postgres;

--
-- Name: goods_receipt_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.goods_receipt_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.goods_receipt_lines_id_seq OWNER TO postgres;

--
-- Name: goods_receipt_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.goods_receipt_lines_id_seq OWNED BY public.goods_receipt_lines.id;


--
-- Name: goods_receipts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.goods_receipts (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    purchase_order_id integer NOT NULL,
    receipt_number text NOT NULL,
    received_date date NOT NULL,
    status text DEFAULT 'received'::text NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.goods_receipts OWNER TO postgres;

--
-- Name: goods_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.goods_receipts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.goods_receipts_id_seq OWNER TO postgres;

--
-- Name: goods_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.goods_receipts_id_seq OWNED BY public.goods_receipts.id;


--
-- Name: item_batch_warehouse_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_batch_warehouse_stock (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    item_batch_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    quantity numeric(14,2) DEFAULT '0'::numeric NOT NULL
);


ALTER TABLE public.item_batch_warehouse_stock OWNER TO postgres;

--
-- Name: item_batch_warehouse_stock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.item_batch_warehouse_stock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_batch_warehouse_stock_id_seq OWNER TO postgres;

--
-- Name: item_batch_warehouse_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.item_batch_warehouse_stock_id_seq OWNED BY public.item_batch_warehouse_stock.id;


--
-- Name: item_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_batches (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    item_id integer NOT NULL,
    batch_number text NOT NULL,
    mfg_date date,
    expiry_date date,
    cost_price numeric(14,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.item_batches OWNER TO postgres;

--
-- Name: item_batches_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.item_batches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_batches_id_seq OWNER TO postgres;

--
-- Name: item_batches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.item_batches_id_seq OWNED BY public.item_batches.id;


--
-- Name: item_bundle_components; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_bundle_components (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    parent_item_id integer NOT NULL,
    component_item_id integer NOT NULL,
    quantity_per_bundle numeric(14,2) DEFAULT '1'::numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.item_bundle_components OWNER TO postgres;

--
-- Name: item_bundle_components_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.item_bundle_components_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_bundle_components_id_seq OWNER TO postgres;

--
-- Name: item_bundle_components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.item_bundle_components_id_seq OWNED BY public.item_bundle_components.id;


--
-- Name: item_warehouse_stock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.item_warehouse_stock (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    item_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    quantity numeric(14,2) DEFAULT '0'::numeric NOT NULL
);


ALTER TABLE public.item_warehouse_stock OWNER TO postgres;

--
-- Name: item_warehouse_stock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.item_warehouse_stock_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.item_warehouse_stock_id_seq OWNER TO postgres;

--
-- Name: item_warehouse_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.item_warehouse_stock_id_seq OWNED BY public.item_warehouse_stock.id;


--
-- Name: items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.items (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    sku text NOT NULL,
    name text NOT NULL,
    description text,
    category text,
    unit text DEFAULT 'pcs'::text NOT NULL,
    barcode text,
    barcode_source text,
    sale_price numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    purchase_price numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    hsn_code text,
    tax_rate numeric(6,2) DEFAULT '0'::numeric NOT NULL,
    reorder_level numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    image_url text,
    parent_item_id integer,
    has_variants boolean DEFAULT false NOT NULL,
    is_bundle boolean DEFAULT false NOT NULL,
    is_bag boolean DEFAULT false NOT NULL,
    allow_backorder boolean DEFAULT false NOT NULL,
    track_batches boolean DEFAULT false NOT NULL,
    max_discount_percent numeric(5,2),
    variant_options jsonb,
    shopify_product_id text,
    shopify_variant_id text,
    shopify_inventory_item_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    archived_at timestamp with time zone,
    max_discount_amount numeric(12,2)
);


ALTER TABLE public.items OWNER TO postgres;

--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.items_id_seq OWNER TO postgres;

--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: job_work_issue_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_work_issue_lines (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    job_work_issue_id integer NOT NULL,
    component_item_id integer NOT NULL,
    quantity numeric(14,2) NOT NULL
);


ALTER TABLE public.job_work_issue_lines OWNER TO postgres;

--
-- Name: job_work_issue_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_work_issue_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_work_issue_lines_id_seq OWNER TO postgres;

--
-- Name: job_work_issue_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_work_issue_lines_id_seq OWNED BY public.job_work_issue_lines.id;


--
-- Name: job_work_issues; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_work_issues (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    job_work_order_id integer NOT NULL,
    issue_number text NOT NULL,
    issue_date date NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.job_work_issues OWNER TO postgres;

--
-- Name: job_work_issues_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_work_issues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_work_issues_id_seq OWNER TO postgres;

--
-- Name: job_work_issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_work_issues_id_seq OWNED BY public.job_work_issues.id;


--
-- Name: job_work_order_components; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_work_order_components (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    job_work_order_id integer NOT NULL,
    component_item_id integer NOT NULL,
    quantity_per_output numeric(14,2) NOT NULL,
    total_quantity numeric(14,2) NOT NULL
);


ALTER TABLE public.job_work_order_components OWNER TO postgres;

--
-- Name: job_work_order_components_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_work_order_components_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_work_order_components_id_seq OWNER TO postgres;

--
-- Name: job_work_order_components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_work_order_components_id_seq OWNED BY public.job_work_order_components.id;


--
-- Name: job_work_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_work_orders (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    jwo_number text NOT NULL,
    supplier_id integer NOT NULL,
    output_item_id integer NOT NULL,
    output_quantity numeric(14,2) NOT NULL,
    source_warehouse_id integer NOT NULL,
    dest_warehouse_id integer NOT NULL,
    vendor_warehouse_id integer NOT NULL,
    job_charge_rate numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    expected_return_date date,
    notes text,
    status text DEFAULT 'draft'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.job_work_orders OWNER TO postgres;

--
-- Name: job_work_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_work_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_work_orders_id_seq OWNER TO postgres;

--
-- Name: job_work_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_work_orders_id_seq OWNED BY public.job_work_orders.id;


--
-- Name: job_work_receipt_components; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_work_receipt_components (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    job_work_receipt_id integer NOT NULL,
    component_item_id integer NOT NULL,
    quantity_consumed numeric(14,2) NOT NULL,
    scrap_quantity numeric(14,2) DEFAULT '0'::numeric NOT NULL
);


ALTER TABLE public.job_work_receipt_components OWNER TO postgres;

--
-- Name: job_work_receipt_components_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_work_receipt_components_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_work_receipt_components_id_seq OWNER TO postgres;

--
-- Name: job_work_receipt_components_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_work_receipt_components_id_seq OWNED BY public.job_work_receipt_components.id;


--
-- Name: job_work_receipts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_work_receipts (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    job_work_order_id integer NOT NULL,
    receipt_number text NOT NULL,
    received_date date NOT NULL,
    finished_quantity numeric(14,2) NOT NULL,
    scrap_quantity numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    job_charge numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    notes text,
    status text DEFAULT 'recorded'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.job_work_receipts OWNER TO postgres;

--
-- Name: job_work_receipts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_work_receipts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.job_work_receipts_id_seq OWNER TO postgres;

--
-- Name: job_work_receipts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_work_receipts_id_seq OWNED BY public.job_work_receipts.id;


--
-- Name: organization_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organization_members (
    id integer NOT NULL,
    user_id integer NOT NULL,
    organization_id integer NOT NULL,
    role text DEFAULT 'owner'::text NOT NULL,
    can_edit_bills boolean DEFAULT false NOT NULL,
    can_edit_stocks boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.organization_members OWNER TO postgres;

--
-- Name: organization_members_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organization_members_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organization_members_id_seq OWNER TO postgres;

--
-- Name: organization_members_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organization_members_id_seq OWNED BY public.organization_members.id;


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.organizations (
    id integer NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    currency text DEFAULT 'INR'::text NOT NULL,
    timezone text DEFAULT 'Asia/Kolkata'::text NOT NULL,
    gst_number text,
    address_line1 text,
    address_line2 text,
    city text,
    state text,
    postal_code text,
    country text DEFAULT 'India'::text,
    logo_url text,
    invoice_footer text,
    plan text DEFAULT 'free'::text NOT NULL,
    subscription_status text DEFAULT 'trialing'::text NOT NULL,
    razorpay_customer_id text,
    razorpay_subscription_id text,
    current_period_end timestamp with time zone,
    trial_ends_at timestamp with time zone,
    shopify_shop_domain text,
    shopify_access_token text,
    shopify_scopes text,
    shopify_location_id text,
    shopify_webhook_registered_at timestamp with time zone,
    shopify_last_webhook_at timestamp with time zone,
    shopify_last_synced_at timestamp with time zone,
    shopify_product_count text,
    shopify_last_order_id text,
    shiprocket_email text,
    shiprocket_token_encrypted text,
    shiprocket_token_expires_at timestamp with time zone,
    shiprocket_pickup_pincode text,
    shiprocket_last_synced_at timestamp with time zone,
    ewb_gstin text,
    ewb_api_username text,
    ewb_api_password_encrypted text,
    ewb_token_encrypted text,
    ewb_token_expires_at timestamp with time zone,
    ewb_connected_at timestamp with time zone,
    ewb_last_error_at timestamp with time zone,
    ewb_last_error_message text,
    e_invoice_enabled boolean DEFAULT false NOT NULL,
    e_invoice_gstin text,
    e_invoice_api_username text,
    e_invoice_api_password_encrypted text,
    e_invoice_client_id_encrypted text,
    e_invoice_client_secret_encrypted text,
    e_invoice_token_encrypted text,
    e_invoice_token_expires_at timestamp with time zone,
    e_invoice_connected_at timestamp with time zone,
    e_invoice_last_error_at timestamp with time zone,
    e_invoice_last_error_message text,
    barcode_prefix text,
    barcode_format text DEFAULT 'code128'::text NOT NULL,
    max_order_discount_percent numeric(5,2),
    max_order_discount_amount numeric(12,2),
    onboarding_completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    login_logo_url text,
    sidebar_logo_url text,
    thermal_logo_url text
);


ALTER TABLE public.organizations OWNER TO postgres;

--
-- Name: organizations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.organizations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.organizations_id_seq OWNER TO postgres;

--
-- Name: organizations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.organizations_id_seq OWNED BY public.organizations.id;


--
-- Name: payment_links; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_links (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    sales_order_id integer NOT NULL,
    razorpay_link_id text NOT NULL,
    short_url text NOT NULL,
    amount numeric(14,2) NOT NULL,
    currency text DEFAULT 'INR'::text NOT NULL,
    status text DEFAULT 'created'::text NOT NULL,
    description text,
    razorpay_payment_id text,
    expires_at timestamp with time zone,
    paid_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    created_by_user_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payment_links OWNER TO postgres;

--
-- Name: payment_links_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payment_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payment_links_id_seq OWNER TO postgres;

--
-- Name: payment_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payment_links_id_seq OWNED BY public.payment_links.id;


--
-- Name: print_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.print_log (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    user_id integer NOT NULL,
    document_type text NOT NULL,
    document_id integer,
    printed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.print_log OWNER TO postgres;

--
-- Name: print_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.print_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.print_log_id_seq OWNER TO postgres;

--
-- Name: print_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.print_log_id_seq OWNED BY public.print_log.id;


--
-- Name: purchase_order_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_order_lines (
    id integer NOT NULL,
    purchase_order_id integer NOT NULL,
    item_id integer NOT NULL,
    description text,
    quantity numeric(14,2) NOT NULL,
    unit_price numeric(14,2) NOT NULL,
    tax_rate numeric(6,2) DEFAULT '0'::numeric NOT NULL,
    discount_percent numeric(6,2) DEFAULT '0'::numeric NOT NULL,
    discount_amount numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    line_subtotal numeric(14,2) NOT NULL,
    line_tax numeric(14,2) NOT NULL,
    line_total numeric(14,2) NOT NULL,
    quantity_received numeric(14,2) DEFAULT '0'::numeric NOT NULL
);


ALTER TABLE public.purchase_order_lines OWNER TO postgres;

--
-- Name: purchase_order_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_order_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_order_lines_id_seq OWNER TO postgres;

--
-- Name: purchase_order_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_order_lines_id_seq OWNED BY public.purchase_order_lines.id;


--
-- Name: purchase_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.purchase_orders (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    order_number text NOT NULL,
    supplier_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    order_date date NOT NULL,
    expected_delivery_date date,
    subtotal numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    tax_total numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    total numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    amount_paid numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    balance_due numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    notes text,
    stock_applied_at timestamp with time zone,
    job_work_receipt_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.purchase_orders OWNER TO postgres;

--
-- Name: purchase_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.purchase_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.purchase_orders_id_seq OWNER TO postgres;

--
-- Name: purchase_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.purchase_orders_id_seq OWNED BY public.purchase_orders.id;


--
-- Name: sales_channel_warehouse_defaults; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_channel_warehouse_defaults (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    sales_channel text NOT NULL,
    warehouse_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.sales_channel_warehouse_defaults OWNER TO postgres;

--
-- Name: sales_channel_warehouse_defaults_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_channel_warehouse_defaults_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_channel_warehouse_defaults_id_seq OWNER TO postgres;

--
-- Name: sales_channel_warehouse_defaults_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_channel_warehouse_defaults_id_seq OWNED BY public.sales_channel_warehouse_defaults.id;


--
-- Name: sales_order_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_order_lines (
    id integer NOT NULL,
    sales_order_id integer NOT NULL,
    item_id integer NOT NULL,
    description text,
    quantity numeric(14,2) NOT NULL,
    quantity_shipped numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    unit_price numeric(14,2) NOT NULL,
    tax_rate numeric(6,2) DEFAULT '0'::numeric NOT NULL,
    discount_percent numeric(6,2) DEFAULT '0'::numeric NOT NULL,
    discount_amount numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    line_subtotal numeric(14,2) NOT NULL,
    line_tax numeric(14,2) NOT NULL,
    line_total numeric(14,2) NOT NULL
);


ALTER TABLE public.sales_order_lines OWNER TO postgres;

--
-- Name: sales_order_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_order_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_order_lines_id_seq OWNER TO postgres;

--
-- Name: sales_order_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_order_lines_id_seq OWNED BY public.sales_order_lines.id;


--
-- Name: sales_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_orders (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    order_number text NOT NULL,
    customer_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    order_date date NOT NULL,
    expected_ship_date date,
    subtotal numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    tax_total numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    total numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    amount_paid numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    balance_due numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    notes text,
    stock_applied_at timestamp with time zone,
    shopify_order_id text,
    external_reference text,
    payment_status text,
    ewb_number text,
    ewb_date timestamp with time zone,
    ewb_valid_until timestamp with time zone,
    ewb_status text,
    ewb_qr_payload text,
    ewb_vehicle_number text,
    ewb_transport_mode text,
    ewb_transporter_name text,
    ewb_transporter_id text,
    ewb_distance_km integer,
    ewb_dispatch_address jsonb,
    ewb_ship_to_address jsonb,
    ewb_cancelled_at timestamp with time zone,
    ewb_cancel_reason text,
    irn text,
    irp_ack_number text,
    irp_ack_date timestamp with time zone,
    irp_qr_payload text,
    irp_status text,
    irp_error text,
    irp_error_code text,
    irp_error_context jsonb,
    irp_cancelled_at timestamp with time zone,
    irp_cancel_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.sales_orders OWNER TO postgres;

--
-- Name: sales_orders_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sales_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.sales_orders_id_seq OWNER TO postgres;

--
-- Name: sales_orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sales_orders_id_seq OWNED BY public.sales_orders.id;


--
-- Name: session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.session (
    sid character varying NOT NULL,
    sess json NOT NULL,
    expire timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.session OWNER TO postgres;

--
-- Name: shipment_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipment_lines (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    shipment_id integer NOT NULL,
    sales_order_line_id integer NOT NULL,
    quantity numeric(14,2) NOT NULL
);


ALTER TABLE public.shipment_lines OWNER TO postgres;

--
-- Name: shipment_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shipment_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shipment_lines_id_seq OWNER TO postgres;

--
-- Name: shipment_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shipment_lines_id_seq OWNED BY public.shipment_lines.id;


--
-- Name: shipments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipments (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    sales_order_id integer NOT NULL,
    shipment_number text NOT NULL,
    ship_date date NOT NULL,
    status text DEFAULT 'shipped'::text NOT NULL,
    notes text,
    shiprocket_order_id text,
    shiprocket_shipment_id text,
    awb text,
    courier_name text,
    label_url text,
    tracking_url text,
    tracking_status text,
    last_tracked_at timestamp with time zone,
    cancel_reason_code text,
    cancel_reason_notes text,
    cancelled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shipments OWNER TO postgres;

--
-- Name: shipments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shipments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shipments_id_seq OWNER TO postgres;

--
-- Name: shipments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shipments_id_seq OWNED BY public.shipments.id;


--
-- Name: shopify_import_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shopify_import_jobs (
    id character varying NOT NULL,
    organization_id integer NOT NULL,
    status text NOT NULL,
    total integer,
    processed integer DEFAULT 0 NOT NULL,
    imported integer DEFAULT 0 NOT NULL,
    skipped integer DEFAULT 0 NOT NULL,
    failed integer DEFAULT 0 NOT NULL,
    failed_orders jsonb DEFAULT '[]'::jsonb NOT NULL,
    from_date text,
    to_date text,
    error text,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone
);


ALTER TABLE public.shopify_import_jobs OWNER TO postgres;

--
-- Name: shopify_oauth_states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shopify_oauth_states (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    state text NOT NULL,
    shop_domain text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shopify_oauth_states OWNER TO postgres;

--
-- Name: shopify_oauth_states_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shopify_oauth_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shopify_oauth_states_id_seq OWNER TO postgres;

--
-- Name: shopify_oauth_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shopify_oauth_states_id_seq OWNED BY public.shopify_oauth_states.id;


--
-- Name: shopify_webhook_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shopify_webhook_events (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    shopify_event_id text NOT NULL,
    topic text NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.shopify_webhook_events OWNER TO postgres;

--
-- Name: shopify_webhook_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shopify_webhook_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shopify_webhook_events_id_seq OWNER TO postgres;

--
-- Name: shopify_webhook_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shopify_webhook_events_id_seq OWNED BY public.shopify_webhook_events.id;


--
-- Name: stock_batch_movements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_batch_movements (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    stock_movement_id integer NOT NULL,
    item_batch_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    quantity numeric(14,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.stock_batch_movements OWNER TO postgres;

--
-- Name: stock_batch_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_batch_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_batch_movements_id_seq OWNER TO postgres;

--
-- Name: stock_batch_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_batch_movements_id_seq OWNED BY public.stock_batch_movements.id;


--
-- Name: stock_movements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_movements (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    item_id integer NOT NULL,
    warehouse_id integer NOT NULL,
    movement_type text NOT NULL,
    quantity numeric(14,2) NOT NULL,
    reference_type text,
    reference_id integer,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.stock_movements OWNER TO postgres;

--
-- Name: stock_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_movements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_movements_id_seq OWNER TO postgres;

--
-- Name: stock_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_movements_id_seq OWNED BY public.stock_movements.id;


--
-- Name: stock_transfer_lines; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_transfer_lines (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    stock_transfer_id integer NOT NULL,
    item_id integer NOT NULL,
    quantity numeric(14,2) NOT NULL
);


ALTER TABLE public.stock_transfer_lines OWNER TO postgres;

--
-- Name: stock_transfer_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_transfer_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_transfer_lines_id_seq OWNER TO postgres;

--
-- Name: stock_transfer_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_transfer_lines_id_seq OWNED BY public.stock_transfer_lines.id;


--
-- Name: stock_transfers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_transfers (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    transfer_number text NOT NULL,
    from_warehouse_id integer NOT NULL,
    to_warehouse_id integer NOT NULL,
    transfer_date date NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.stock_transfers OWNER TO postgres;

--
-- Name: stock_transfers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_transfers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_transfers_id_seq OWNER TO postgres;

--
-- Name: stock_transfers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_transfers_id_seq OWNED BY public.stock_transfers.id;


--
-- Name: supplier_payment_allocations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier_payment_allocations (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    payment_id integer NOT NULL,
    purchase_order_id integer NOT NULL,
    amount numeric(14,2) NOT NULL
);


ALTER TABLE public.supplier_payment_allocations OWNER TO postgres;

--
-- Name: supplier_payment_allocations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_payment_allocations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplier_payment_allocations_id_seq OWNER TO postgres;

--
-- Name: supplier_payment_allocations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_payment_allocations_id_seq OWNED BY public.supplier_payment_allocations.id;


--
-- Name: supplier_payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.supplier_payments (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    supplier_id integer NOT NULL,
    payment_date date NOT NULL,
    amount numeric(14,2) NOT NULL,
    mode text NOT NULL,
    reference_number text,
    notes text,
    bank_account_label text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.supplier_payments OWNER TO postgres;

--
-- Name: supplier_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.supplier_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.supplier_payments_id_seq OWNER TO postgres;

--
-- Name: supplier_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.supplier_payments_id_seq OWNED BY public.supplier_payments.id;


--
-- Name: suppliers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.suppliers (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    name text NOT NULL,
    email text,
    phone text,
    company text,
    gst_number text,
    address text,
    notes text,
    outstanding_payable numeric(14,2) DEFAULT '0'::numeric NOT NULL,
    is_job_worker boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.suppliers OWNER TO postgres;

--
-- Name: suppliers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.suppliers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.suppliers_id_seq OWNER TO postgres;

--
-- Name: suppliers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.suppliers_id_seq OWNED BY public.suppliers.id;


--
-- Name: team_invitations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team_invitations (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    email text NOT NULL,
    role text DEFAULT 'member'::text NOT NULL,
    token text NOT NULL,
    invited_by_user_id integer NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    accepted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.team_invitations OWNER TO postgres;

--
-- Name: team_invitations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.team_invitations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.team_invitations_id_seq OWNER TO postgres;

--
-- Name: team_invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.team_invitations_id_seq OWNED BY public.team_invitations.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    clerk_user_id text,
    email text NOT NULL,
    username text,
    name text,
    password_hash text,
    email_verified_at timestamp with time zone,
    verify_token text,
    verify_token_expires_at timestamp with time zone,
    reset_token text,
    reset_token_expires_at timestamp with time zone,
    is_super_admin boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: warehouses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.warehouses (
    id integer NOT NULL,
    organization_id integer NOT NULL,
    name text NOT NULL,
    code text NOT NULL,
    address_line1 text,
    city text,
    state text,
    country text,
    is_default boolean DEFAULT false NOT NULL,
    is_virtual boolean DEFAULT false NOT NULL,
    job_worker_supplier_id integer,
    shopify_location_id text,
    shopify_location_name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.warehouses OWNER TO postgres;

--
-- Name: warehouses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.warehouses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.warehouses_id_seq OWNER TO postgres;

--
-- Name: warehouses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.warehouses_id_seq OWNED BY public.warehouses.id;


--
-- Name: customer_payment_allocations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payment_allocations ALTER COLUMN id SET DEFAULT nextval('public.customer_payment_allocations_id_seq'::regclass);


--
-- Name: customer_payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payments ALTER COLUMN id SET DEFAULT nextval('public.customer_payments_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: email_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_log ALTER COLUMN id SET DEFAULT nextval('public.email_log_id_seq'::regclass);


--
-- Name: email_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_settings ALTER COLUMN id SET DEFAULT nextval('public.email_settings_id_seq'::regclass);


--
-- Name: goods_receipt_lines id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipt_lines ALTER COLUMN id SET DEFAULT nextval('public.goods_receipt_lines_id_seq'::regclass);


--
-- Name: goods_receipts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipts ALTER COLUMN id SET DEFAULT nextval('public.goods_receipts_id_seq'::regclass);


--
-- Name: item_batch_warehouse_stock id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batch_warehouse_stock ALTER COLUMN id SET DEFAULT nextval('public.item_batch_warehouse_stock_id_seq'::regclass);


--
-- Name: item_batches id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batches ALTER COLUMN id SET DEFAULT nextval('public.item_batches_id_seq'::regclass);


--
-- Name: item_bundle_components id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_bundle_components ALTER COLUMN id SET DEFAULT nextval('public.item_bundle_components_id_seq'::regclass);


--
-- Name: item_warehouse_stock id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_warehouse_stock ALTER COLUMN id SET DEFAULT nextval('public.item_warehouse_stock_id_seq'::regclass);


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: job_work_issue_lines id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issue_lines ALTER COLUMN id SET DEFAULT nextval('public.job_work_issue_lines_id_seq'::regclass);


--
-- Name: job_work_issues id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issues ALTER COLUMN id SET DEFAULT nextval('public.job_work_issues_id_seq'::regclass);


--
-- Name: job_work_order_components id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_order_components ALTER COLUMN id SET DEFAULT nextval('public.job_work_order_components_id_seq'::regclass);


--
-- Name: job_work_orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_orders ALTER COLUMN id SET DEFAULT nextval('public.job_work_orders_id_seq'::regclass);


--
-- Name: job_work_receipt_components id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipt_components ALTER COLUMN id SET DEFAULT nextval('public.job_work_receipt_components_id_seq'::regclass);


--
-- Name: job_work_receipts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipts ALTER COLUMN id SET DEFAULT nextval('public.job_work_receipts_id_seq'::regclass);


--
-- Name: organization_members id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_members ALTER COLUMN id SET DEFAULT nextval('public.organization_members_id_seq'::regclass);


--
-- Name: organizations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations ALTER COLUMN id SET DEFAULT nextval('public.organizations_id_seq'::regclass);


--
-- Name: payment_links id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_links ALTER COLUMN id SET DEFAULT nextval('public.payment_links_id_seq'::regclass);


--
-- Name: print_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.print_log ALTER COLUMN id SET DEFAULT nextval('public.print_log_id_seq'::regclass);


--
-- Name: purchase_order_lines id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_lines ALTER COLUMN id SET DEFAULT nextval('public.purchase_order_lines_id_seq'::regclass);


--
-- Name: purchase_orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders ALTER COLUMN id SET DEFAULT nextval('public.purchase_orders_id_seq'::regclass);


--
-- Name: sales_channel_warehouse_defaults id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_channel_warehouse_defaults ALTER COLUMN id SET DEFAULT nextval('public.sales_channel_warehouse_defaults_id_seq'::regclass);


--
-- Name: sales_order_lines id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_order_lines ALTER COLUMN id SET DEFAULT nextval('public.sales_order_lines_id_seq'::regclass);


--
-- Name: sales_orders id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_orders ALTER COLUMN id SET DEFAULT nextval('public.sales_orders_id_seq'::regclass);


--
-- Name: shipment_lines id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_lines ALTER COLUMN id SET DEFAULT nextval('public.shipment_lines_id_seq'::regclass);


--
-- Name: shipments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipments ALTER COLUMN id SET DEFAULT nextval('public.shipments_id_seq'::regclass);


--
-- Name: shopify_oauth_states id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopify_oauth_states ALTER COLUMN id SET DEFAULT nextval('public.shopify_oauth_states_id_seq'::regclass);


--
-- Name: shopify_webhook_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopify_webhook_events ALTER COLUMN id SET DEFAULT nextval('public.shopify_webhook_events_id_seq'::regclass);


--
-- Name: stock_batch_movements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_batch_movements ALTER COLUMN id SET DEFAULT nextval('public.stock_batch_movements_id_seq'::regclass);


--
-- Name: stock_movements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements ALTER COLUMN id SET DEFAULT nextval('public.stock_movements_id_seq'::regclass);


--
-- Name: stock_transfer_lines id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfer_lines ALTER COLUMN id SET DEFAULT nextval('public.stock_transfer_lines_id_seq'::regclass);


--
-- Name: stock_transfers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfers ALTER COLUMN id SET DEFAULT nextval('public.stock_transfers_id_seq'::regclass);


--
-- Name: supplier_payment_allocations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payment_allocations ALTER COLUMN id SET DEFAULT nextval('public.supplier_payment_allocations_id_seq'::regclass);


--
-- Name: supplier_payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payments ALTER COLUMN id SET DEFAULT nextval('public.supplier_payments_id_seq'::regclass);


--
-- Name: suppliers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);


--
-- Name: team_invitations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_invitations ALTER COLUMN id SET DEFAULT nextval('public.team_invitations_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: warehouses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses ALTER COLUMN id SET DEFAULT nextval('public.warehouses_id_seq'::regclass);


--
-- Data for Name: customer_payment_allocations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_payment_allocations (id, organization_id, payment_id, sales_order_id, amount) FROM stdin;
1	1	1	1	2499.00
2	1	2	2	2499.00
3	1	3	3	2499.00
\.


--
-- Data for Name: customer_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_payments (id, organization_id, customer_id, payment_date, amount, mode, reference_number, notes, bank_account_label, created_at, updated_at) FROM stdin;
1	1	1	2026-06-09	2500.00	cash	\N	POS sale POS-260609-0464 · Channel: POS	\N	2026-06-09 12:10:52.544664+00	2026-06-09 12:10:52.544664+00
2	1	1	2026-06-09	2500.00	cash	\N	POS sale POS-260609-7327 · Channel: POS	\N	2026-06-09 12:31:14.83817+00	2026-06-09 12:31:14.83817+00
3	1	1	2026-06-09	2500.00	cash	\N	POS sale POS-260609-1958 · Channel: POS	\N	2026-06-09 15:52:34.850695+00	2026-06-09 15:52:34.850695+00
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, organization_id, name, email, phone, company, gst_number, billing_address, shipping_address, place_of_supply, notes, outstanding_balance, created_at, updated_at) FROM stdin;
1	1	Walk-in Customer	\N	\N	\N	\N	\N	\N	\N	Auto-created for POS walk-in sales	-7500.00	2026-06-09 12:10:52.528308+00	2026-06-09 15:52:34.862+00
\.


--
-- Data for Name: einvoice_bulk_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.einvoice_bulk_batches (id, organization_id, status, total, processed, succeeded, failed, skipped, order_ids_in_order, results, created_at, updated_at, started_at, completed_at, concurrency, recovery_claimed_at) FROM stdin;
\.


--
-- Data for Name: email_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_log (id, organization_id, sales_order_id, kind, recipient, subject, status, error_message, sent_by_user_id, sent_at) FROM stdin;
\.


--
-- Data for Name: email_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_settings (id, organization_id, host, port, secure, username, password_encrypted, from_email, from_name, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: goods_receipt_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.goods_receipt_lines (id, organization_id, goods_receipt_id, purchase_order_line_id, quantity) FROM stdin;
\.


--
-- Data for Name: goods_receipts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.goods_receipts (id, organization_id, purchase_order_id, receipt_number, received_date, status, notes, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: item_batch_warehouse_stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item_batch_warehouse_stock (id, organization_id, item_batch_id, warehouse_id, quantity) FROM stdin;
\.


--
-- Data for Name: item_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item_batches (id, organization_id, item_id, batch_number, mfg_date, expiry_date, cost_price, created_at) FROM stdin;
\.


--
-- Data for Name: item_bundle_components; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item_bundle_components (id, organization_id, parent_item_id, component_item_id, quantity_per_bundle, created_at) FROM stdin;
\.


--
-- Data for Name: item_warehouse_stock; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.item_warehouse_stock (id, organization_id, item_id, warehouse_id, quantity) FROM stdin;
3	1	4	1	50.00
4	1	5	1	50.00
6	1	7	1	50.00
7	1	8	1	50.00
8	1	9	1	50.00
9	1	10	1	50.00
10	1	11	1	50.00
11	1	12	1	50.00
12	1	13	1	50.00
13	1	14	1	50.00
14	1	15	1	50.00
15	1	16	1	50.00
16	1	17	1	50.00
17	1	18	1	50.00
18	1	19	1	50.00
19	1	20	1	50.00
20	1	21	1	50.00
21	1	22	1	50.00
23	1	24	1	50.00
24	1	25	1	50.00
25	1	26	1	50.00
26	1	27	1	50.00
27	1	28	1	50.00
28	1	29	1	50.00
29	1	30	1	50.00
30	1	31	1	50.00
31	1	32	1	50.00
32	1	33	1	50.00
1	1	2	1	49.00
5	1	6	1	49.00
33	1	35	1	20.00
34	1	36	1	10.00
35	1	37	1	5.00
2	1	3	1	49.00
22	1	23	1	20.00
36	1	23	2	30.00
37	1	38	1	50.00
38	1	40	1	30.00
39	1	41	1	20.00
40	1	42	1	50.00
41	1	44	1	30.00
42	1	45	1	20.00
43	1	46	1	50.00
44	1	48	1	30.00
45	1	49	1	20.00
46	1	50	1	50.00
47	1	52	1	30.00
48	1	53	1	20.00
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.items (id, organization_id, sku, name, description, category, unit, barcode, barcode_source, sale_price, purchase_price, hsn_code, tax_rate, reorder_level, image_url, parent_item_id, has_variants, is_bundle, is_bag, allow_backorder, track_batches, max_discount_percent, variant_options, shopify_product_id, shopify_variant_id, shopify_inventory_item_id, created_at, updated_at, archived_at, max_discount_amount) FROM stdin;
3	1	MMW-5402-3XL-KURTI	Aananthy Maternity Kurti Set (Size 3XL)	Aananthy Maternity Kurti Set (Size 3XL)	Maternity Kurti Set	pcs	26857611546468	manual	2499.00	2499.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.867+00	2026-06-09 17:19:39.867+00	\N
4	1	MMW-5399-L-KURTI	Aananthy Maternity Kurti Set (Size L)	Aananthy Maternity Kurti Set (Size L)	Maternity Kurti Set	pcs	26857611248164	manual	2499.00	2499.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.869+00	2026-06-09 17:19:39.869+00	\N
7	1	MMW-5400-XL-KURTI	Aananthy Maternity Kurti Set (Size XL)	Aananthy Maternity Kurti Set (Size XL)	Maternity Kurti Set	pcs	26857611380932	manual	2499.00	2499.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.893+00	2026-06-09 17:19:39.893+00	\N
8	1	MMW-5623-2XL-KURTI	Aarvitha_V1 Maternity Kurti Set (Size 2XL)	Aarvitha_V1 Maternity Kurti Set (Size 2XL)	Maternity Kurti Set	pcs	20466683861092	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.906+00	2026-06-09 17:19:39.905+00	\N
9	1	MMW-5624-3XL-KURTI	Aarvitha_V1 Maternity Kurti Set (Size 3XL)	Aarvitha_V1 Maternity Kurti Set (Size 3XL)	Maternity Kurti Set	pcs	80466683993860	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.93+00	2026-06-09 17:19:39.93+00	\N
10	1	MMW-5621-L-KURTI	Aarvitha_V1 Maternity Kurti Set (Size L)	Aarvitha_V1 Maternity Kurti Set (Size L)	Maternity Kurti Set	pcs	30466683695556	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.933+00	2026-06-09 17:19:39.933+00	\N
11	1	MMW-5620-M-KURTI	Aarvitha_V1 Maternity Kurti Set (Size M)	Aarvitha_V1 Maternity Kurti Set (Size M)	Maternity Kurti Set	pcs	20466683562788	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.96+00	2026-06-09 17:19:39.96+00	\N
13	1	MMW-5622-XL-KURTI	Aarvitha_V1 Maternity Kurti Set (Size XL)	Aarvitha_V1 Maternity Kurti Set (Size XL)	Maternity Kurti Set	pcs	10466683728324	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.963+00	2026-06-09 17:19:39.963+00	\N
12	1	MMW-5619-S-KURTI	Aarvitha_V1 Maternity Kurti Set (Size S)	Aarvitha_V1 Maternity Kurti Set (Size S)	Maternity Kurti Set	pcs	90466683430020	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.968+00	2026-06-09 17:19:39.968+00	\N
14	1	MMW-5629-2XL-KURTI	Aarvitha_V2 Maternity Kurti Set (Size 2XL)	Aarvitha_V2 Maternity Kurti Set (Size 2XL)	Maternity Kurti Set	pcs	50466684456004	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.975+00	2026-06-09 17:19:39.975+00	\N
16	1	MMW-5627-L-KURTI	Aarvitha_V2 Maternity Kurti Set (Size L)	Aarvitha_V2 Maternity Kurti Set (Size L)	Maternity Kurti Set	pcs	70466684290468	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:40.013+00	2026-06-09 17:19:40.013+00	\N
15	1	MMW-5630-3XL-KURTI	Aarvitha_V2 Maternity Kurti Set (Size 3XL)	Aarvitha_V2 Maternity Kurti Set (Size 3XL)	Maternity Kurti Set	pcs	10466684588772	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:40.015+00	2026-06-09 17:19:40.015+00	\N
17	1	MMW-5626-M-KURTI	Aarvitha_V2 Maternity Kurti Set (Size M)	Aarvitha_V2 Maternity Kurti Set (Size M)	Maternity Kurti Set	pcs	50466684157700	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:40.04+00	2026-06-09 17:19:40.04+00	\N
20	1	MMW-5809-2XL-KURTI	Aiswarya Maternity Kurti Set (Size 2XL)	Aiswarya Maternity Kurti Set (Size 2XL)	Maternity Kurti Set	pcs	38575920157220	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.638+00	2026-06-09 17:19:45.638+00	\N
22	1	MMW-5807-L-KURTI	Aiswarya Maternity Kurti Set (Size L)	Aiswarya Maternity Kurti Set (Size L)	Maternity Kurti Set	pcs	38575910091684	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.638+00	2026-06-09 17:19:45.638+00	\N
23	1	MMW-5806-M-KURTI	Aiswarya Maternity Kurti Set (Size M)	Aiswarya Maternity Kurti Set (Size M)	Maternity Kurti Set	pcs	38575910058916	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.642+00	2026-06-09 17:19:45.642+00	\N
18	1	MMW-5625-S-KURTI	Aarvitha_V2 Maternity Kurti Set (Size S)	Aarvitha_V2 Maternity Kurti Set (Size S)	Maternity Kurti Set	pcs	80466684024932	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.648+00	2026-06-09 17:19:45.647+00	\N
21	1	MMW-5810-3XL-KURTI	Aiswarya Maternity Kurti Set (Size 3XL)	Aiswarya Maternity Kurti Set (Size 3XL)	Maternity Kurti Set	pcs	38575920189988	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.649+00	2026-06-09 17:19:45.649+00	\N
24	1	MMW-5805-S-KURTI	Aiswarya Maternity Kurti Set (Size S)	Aiswarya Maternity Kurti Set (Size S)	Maternity Kurti Set	pcs	38575910026148	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.699+00	2026-06-09 17:19:45.699+00	\N
26	1	MMW-5425-2XL-KURTI	Anicham_V1 Maternity Kurti Set (Size 2XL)	Anicham_V1 Maternity Kurti Set (Size 2XL)	Maternity Kurti Set	pcs	70466672688708	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.708+00	2026-06-09 17:19:45.708+00	\N
27	1	MMW-5426-3XL-KURTI	Anicham_V1 Maternity Kurti Set (Size 3XL)	Anicham_V1 Maternity Kurti Set (Size 3XL)	Maternity Kurti Set	pcs	60466672721476	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.713+00	2026-06-09 17:19:45.713+00	\N
25	1	MMW-5808-XL-KURTI	Aiswarya Maternity Kurti Set (Size XL)	Aiswarya Maternity Kurti Set (Size XL)	Maternity Kurti Set	pcs	38575910124452	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.718+00	2026-06-09 17:19:45.718+00	\N
29	1	MMW-5422-M-KURTI	Anicham_V1 Maternity Kurti Set (Size M)	Anicham_V1 Maternity Kurti Set (Size M)	Maternity Kurti Set	pcs	20466672390404	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.723+00	2026-06-09 17:19:45.723+00	\N
28	1	MMW-5423-L-KURTI	Anicham_V1 Maternity Kurti Set (Size L)	Anicham_V1 Maternity Kurti Set (Size L)	Maternity Kurti Set	pcs	70466672423172	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.723+00	2026-06-09 17:19:45.723+00	\N
30	1	MMW-5421-S-KURTI	Anicham_V1 Maternity Kurti Set (Size S)	Anicham_V1 Maternity Kurti Set (Size S)	Maternity Kurti Set	pcs	80466672257636	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.757+00	2026-06-09 17:19:45.757+00	\N
31	1	MMW-5424-XL-KURTI	Anicham_V1 Maternity Kurti Set (Size XL)	Anicham_V1 Maternity Kurti Set (Size XL)	Maternity Kurti Set	pcs	10466672555940	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.773+00	2026-06-09 17:19:45.772+00	\N
32	1	MMW-5431-2XL-KURTI	Anicham_V2 Maternity Kurti Set (Size 2XL)	Anicham_V2 Maternity Kurti Set (Size 2XL)	Maternity Kurti Set	pcs	40466683235588	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.776+00	2026-06-09 17:19:45.776+00	\N
1	1	WIDGET-001	Sample widget	Demo description (optional)	Demo	pcs	ANAN00000002	auto	199.00	120.00	3926	18.00	10.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 09:02:12.372959+00	2026-06-09 17:19:50.352+00	2026-06-09 17:19:50.352+00	\N
33	1	MMW-5432-3XL-KURTI	Anicham_V2 Maternity Kurti Set (Size 3XL)	Anicham_V2 Maternity Kurti Set (Size 3XL)	Maternity Kurti Set	pcs	70466683368356	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:50.357+00	2026-06-09 17:19:50.357+00	\N
36	1	TEDEM	Test — M	\N	Demo	pcs	ANAN00000004	auto	299.00	350.00	\N	18.00	5.00	\N	34	f	f	f	f	f	\N	{"Size": "M"}	\N	\N	\N	2026-06-09 13:47:41.326647+00	2026-06-09 17:20:20.844+00	2026-06-09 17:20:20.844+00	\N
35	1	TEDES	Test — S	\N	Demo	pcs	ANAN00000003	auto	299.00	300.00	\N	18.00	5.00	\N	34	f	f	f	f	f	\N	{"Size": "S"}	\N	\N	\N	2026-06-09 13:47:41.326647+00	2026-06-09 17:20:24.629+00	2026-06-09 17:20:24.629+00	\N
34	1	Test	Test	\N	Demo	pcs	DEMO-TEST	manual	300.00	250.00	\N	18.00	5.00	\N	\N	t	f	f	f	f	\N	{"axes": ["Size"]}	\N	\N	\N	2026-06-09 13:41:05.284015+00	2026-06-09 17:20:28.072+00	2026-06-09 17:20:28.072+00	\N
2	1	MMW-5401-2XL-KURTI	Aananthy Maternity Kurti Set (Size 2XL)	Aananthy Maternity Kurti Set (Size 2XL)	Maternity Kurti Set	pcs	ANAN00000001	manual	2499.00	2499.00	0	0.00	0.00	/objects/uploads/org-1/8fc10ffb-2358-4ace-872a-7582180a4bbe	\N	t	f	f	f	f	\N	{"axes": ["Size"]}	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 16:59:06.531+00	2026-06-09 16:59:06.53+00	\N
5	1	MMW-5398-M-KURTI	Aananthy Maternity Kurti Set (Size M)	Aananthy Maternity Kurti Set (Size M)	Maternity Kurti Set	pcs	26857611115396	manual	2499.00	2499.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.893+00	2026-06-09 17:19:39.893+00	\N
6	1	MMW-5397-S-KURTI	Aananthy Maternity Kurti Set (Size S)	Aananthy Maternity Kurti Set (Size S)	Maternity Kurti Set	pcs	26857611082628	manual	2499.00	2499.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:39.894+00	2026-06-09 17:19:39.894+00	\N
19	1	MMW-5628-XL-KURTI	Aarvitha_V2 Maternity Kurti Set (Size XL)	Aarvitha_V2 Maternity Kurti Set (Size XL)	Maternity Kurti Set	pcs	80466684323236	manual	1799.00	1799.00	0	0.00	0.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 11:00:48.272458+00	2026-06-09 17:19:45.641+00	2026-06-09 17:19:45.641+00	\N
37	1	TEDEL	Test — L	\N	Demo	pcs	ANAN00000005	auto	299.00	360.00	\N	18.00	5.00	\N	34	f	f	f	f	f	\N	{"Size": "L"}	\N	\N	\N	2026-06-09 13:47:41.326647+00	2026-06-09 17:20:14.561+00	2026-06-09 17:20:14.561+00	\N
52	1	TSHIRT-001-RED-S	T-Shirt Classic Red S	\N	Apparel	pcs	ANAN00000002	auto	299.00	399.00	6109	5.00	0.00	\N	51	f	f	f	f	f	\N	{"Attribute 1": "Red", "Attribute 2": "S"}	\N	\N	\N	2026-06-10 06:31:18.157933+00	2026-06-10 06:31:18.157933+00	\N	\N
53	1	TSHIRT-001-RED-L	T-Shirt Classic Red L	\N	Apparel	pcs	ANAN00000003	auto	299.00	399.00	6109	5.00	0.00	\N	51	f	f	f	f	f	\N	{"Attribute 1": "Red", "Attribute 2": "L"}	\N	\N	\N	2026-06-10 06:31:18.157933+00	2026-06-10 06:31:18.157933+00	\N	\N
38	1	WIDGET-001	Sample Widget	A simple standalone product	Electronics	pcs	8.90123E+12	manual	199.00	249.00	3926	18.00	10.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 18:01:27.352923+00	2026-06-09 18:03:46.927+00	2026-06-09 18:03:46.927+00	\N
41	1	TSHIRT-001-RED-L	T-Shirt Classic Red L	\N	Apparel	pcs	ANAN00000003	auto	299.00	399.00	6109	5.00	0.00	\N	39	f	f	f	f	f	\N	{"Size": "Red"}	\N	\N	\N	2026-06-09 18:02:30.379707+00	2026-06-09 18:04:02.548+00	2026-06-09 18:04:02.548+00	\N
40	1	TSHIRT-001-RED-S	T-Shirt Classic Red S	\N	Apparel	pcs	ANAN00000002	auto	299.00	399.00	6109	5.00	0.00	\N	39	f	f	f	f	f	\N	{"Size": "Red"}	\N	\N	\N	2026-06-09 18:02:30.379707+00	2026-06-09 18:04:07.442+00	2026-06-09 18:04:07.442+00	\N
39	1	TSHIRT-001	TSHIRT-001	\N	Apparel	pcs	ANAN00000001	manual	0.00	0.00	6109	5.00	5.00	\N	\N	t	f	f	f	f	\N	{"axes": ["Size"]}	\N	\N	\N	2026-06-09 18:01:27.352923+00	2026-06-09 18:04:13.915+00	2026-06-09 18:04:13.915+00	\N
42	1	WIDGET-001	Sample Widget	A simple standalone product	Electronics	pcs	8.90123E+12	manual	199.00	249.00	3926	18.00	10.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 18:04:50.959382+00	2026-06-09 18:05:15.432+00	2026-06-09 18:05:15.432+00	\N
44	1	TSHIRT-001-RED-S	T-Shirt Classic Red S	\N	Apparel	pcs	ANAN00000002	auto	299.00	399.00	6109	5.00	0.00	\N	43	f	f	f	f	f	\N	{"Attribute 1": "Red", "Attribute 2": "S"}	\N	\N	\N	2026-06-09 18:04:50.959382+00	2026-06-09 18:09:55.323+00	2026-06-09 18:09:55.322+00	\N
45	1	TSHIRT-001-RED-L	T-Shirt Classic Red L	\N	Apparel	pcs	ANAN00000003	auto	299.00	399.00	6109	5.00	0.00	\N	43	f	f	f	f	f	\N	{"Attribute 1": "Red", "Attribute 2": "L"}	\N	\N	\N	2026-06-09 18:04:50.959382+00	2026-06-09 18:09:55.33+00	2026-06-09 18:09:55.33+00	\N
43	1	TSHIRT-001	TSHIRT-001	\N	Apparel	pcs	ANAN00000001	auto	0.00	0.00	6109	5.00	5.00	\N	\N	t	f	f	f	f	\N	{"axes": ["Attribute 1", "Attribute 2"]}	\N	\N	\N	2026-06-09 18:04:50.959382+00	2026-06-09 18:10:04.628+00	2026-06-09 18:10:04.628+00	\N
46	1	SKU	T-Shirt 2XL	A simple standalone product	Electronics	pcs	ANAN00000004	auto	249.00	249.00	3926	18.00	10.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-09 18:10:17.996977+00	2026-06-10 06:25:02.363+00	2026-06-10 06:25:02.363+00	\N
49	1	TSHIRT-001-RED-L	T-Shirt Classic Red L	\N	Apparel	pcs	ANAN00000003	auto	299.00	399.00	6109	5.00	0.00	\N	47	f	f	f	f	f	\N	{"Attribute 1": "Red", "Attribute 2": "L"}	\N	\N	\N	2026-06-09 18:10:17.996977+00	2026-06-10 06:25:11.383+00	2026-06-10 06:25:11.383+00	\N
48	1	TSHIRT-001-RED-S	T-Shirt Classic Red S	\N	Apparel	pcs	ANAN00000002	auto	299.00	399.00	6109	5.00	0.00	\N	47	f	f	f	f	f	\N	{"Attribute 1": "Red", "Attribute 2": "S"}	\N	\N	\N	2026-06-09 18:10:17.996977+00	2026-06-10 06:25:11.391+00	2026-06-10 06:25:11.391+00	\N
47	1	TSHIRT-001	TSHIRT-001	\N	Apparel	pcs	ANAN00000001	auto	0.00	0.00	6109	5.00	5.00	\N	\N	t	f	f	f	f	\N	{"axes": ["Attribute 1", "Attribute 2"]}	\N	\N	\N	2026-06-09 18:10:17.996977+00	2026-06-10 06:25:11.4+00	2026-06-10 06:25:11.4+00	\N
50	1	WIDGET-001	Sample Widget	A simple standalone product	Electronics	pcs	8901234567894	manual	199.00	249.00	3926	18.00	10.00	\N	\N	f	f	f	f	f	\N	\N	\N	\N	\N	2026-06-10 06:31:18.157933+00	2026-06-10 06:31:18.157933+00	\N	\N
51	1	TSHIRT-001	T-Shirt Classic	\N	Apparel	pcs	ANAN00000001	auto	0.00	0.00	6109	5.00	5.00	\N	\N	t	f	f	f	f	\N	{"axes": ["Attribute 1", "Attribute 2"]}	\N	\N	\N	2026-06-10 06:31:18.157933+00	2026-06-10 06:31:18.157933+00	\N	\N
\.


--
-- Data for Name: job_work_issue_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_work_issue_lines (id, organization_id, job_work_issue_id, component_item_id, quantity) FROM stdin;
\.


--
-- Data for Name: job_work_issues; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_work_issues (id, organization_id, job_work_order_id, issue_number, issue_date, notes, created_at) FROM stdin;
\.


--
-- Data for Name: job_work_order_components; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_work_order_components (id, organization_id, job_work_order_id, component_item_id, quantity_per_output, total_quantity) FROM stdin;
\.


--
-- Data for Name: job_work_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_work_orders (id, organization_id, jwo_number, supplier_id, output_item_id, output_quantity, source_warehouse_id, dest_warehouse_id, vendor_warehouse_id, job_charge_rate, expected_return_date, notes, status, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: job_work_receipt_components; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_work_receipt_components (id, organization_id, job_work_receipt_id, component_item_id, quantity_consumed, scrap_quantity) FROM stdin;
\.


--
-- Data for Name: job_work_receipts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_work_receipts (id, organization_id, job_work_order_id, receipt_number, received_date, finished_quantity, scrap_quantity, job_charge, notes, status, created_at) FROM stdin;
\.


--
-- Data for Name: organization_members; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organization_members (id, user_id, organization_id, role, can_edit_bills, can_edit_stocks, created_at) FROM stdin;
1	1	1	owner	f	f	2026-06-09 06:22:58.513741+00
2	2	1	viewer	f	f	2026-06-09 13:17:59.888156+00
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.organizations (id, name, slug, currency, timezone, gst_number, address_line1, address_line2, city, state, postal_code, country, logo_url, invoice_footer, plan, subscription_status, razorpay_customer_id, razorpay_subscription_id, current_period_end, trial_ends_at, shopify_shop_domain, shopify_access_token, shopify_scopes, shopify_location_id, shopify_webhook_registered_at, shopify_last_webhook_at, shopify_last_synced_at, shopify_product_count, shopify_last_order_id, shiprocket_email, shiprocket_token_encrypted, shiprocket_token_expires_at, shiprocket_pickup_pincode, shiprocket_last_synced_at, ewb_gstin, ewb_api_username, ewb_api_password_encrypted, ewb_token_encrypted, ewb_token_expires_at, ewb_connected_at, ewb_last_error_at, ewb_last_error_message, e_invoice_enabled, e_invoice_gstin, e_invoice_api_username, e_invoice_api_password_encrypted, e_invoice_client_id_encrypted, e_invoice_client_secret_encrypted, e_invoice_token_encrypted, e_invoice_token_expires_at, e_invoice_connected_at, e_invoice_last_error_at, e_invoice_last_error_message, barcode_prefix, barcode_format, max_order_discount_percent, max_order_discount_amount, onboarding_completed_at, created_at, updated_at, login_logo_url, sidebar_logo_url, thermal_logo_url) FROM stdin;
1	anand's Workspace	anand	INR	Asia/Kolkata	\N	\N	\N	\N	\N	\N	India	/objects/uploads/org-1/9139637b-aaf6-41de-867d-33b8530cc755	\N	free	trialing	\N	\N	\N	2026-06-23 06:22:58.508+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	code128	\N	\N	\N	2026-06-09 06:22:58.510767+00	2026-06-09 15:54:07.156+00	/objects/uploads/org-1/21ce5f07-d9e3-4b86-9d0d-a49f10f2e174	/objects/uploads/org-1/6be0c230-f06d-4507-bff9-62dca0e7fe38	/objects/uploads/org-1/773c2d53-db2a-4a11-a8b5-fb8a0b7898be
\.


--
-- Data for Name: payment_links; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_links (id, organization_id, sales_order_id, razorpay_link_id, short_url, amount, currency, status, description, razorpay_payment_id, expires_at, paid_at, cancelled_at, created_by_user_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: print_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.print_log (id, organization_id, user_id, document_type, document_id, printed_at) FROM stdin;
1	1	1	pos_receipt	1	2026-06-09 12:10:55.104097+00
2	1	1	sales_order_thermal	1	2026-06-09 12:30:37.551599+00
3	1	1	pos_receipt	2	2026-06-09 12:31:16.375199+00
4	1	1	sales_order_thermal	2	2026-06-09 15:52:13.356813+00
5	1	1	pos_receipt	3	2026-06-09 15:52:36.627482+00
6	1	1	sales_order_invoice	3	2026-06-09 15:53:25.30138+00
\.


--
-- Data for Name: purchase_order_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchase_order_lines (id, purchase_order_id, item_id, description, quantity, unit_price, tax_rate, discount_percent, discount_amount, line_subtotal, line_tax, line_total, quantity_received) FROM stdin;
\.


--
-- Data for Name: purchase_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.purchase_orders (id, organization_id, order_number, supplier_id, warehouse_id, status, order_date, expected_delivery_date, subtotal, tax_total, total, amount_paid, balance_due, notes, stock_applied_at, job_work_receipt_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sales_channel_warehouse_defaults; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_channel_warehouse_defaults (id, organization_id, sales_channel, warehouse_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sales_order_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_order_lines (id, sales_order_id, item_id, description, quantity, quantity_shipped, unit_price, tax_rate, discount_percent, discount_amount, line_subtotal, line_tax, line_total) FROM stdin;
1	1	2	\N	1.00	1.00	2499.00	0.00	0.00	0.00	2499.00	0.00	2499.00
2	2	6	\N	1.00	1.00	2499.00	0.00	0.00	0.00	2499.00	0.00	2499.00
3	3	3	\N	1.00	1.00	2499.00	0.00	0.00	0.00	2499.00	0.00	2499.00
\.


--
-- Data for Name: sales_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_orders (id, organization_id, order_number, customer_id, warehouse_id, status, order_date, expected_ship_date, subtotal, tax_total, total, amount_paid, balance_due, notes, stock_applied_at, shopify_order_id, external_reference, payment_status, ewb_number, ewb_date, ewb_valid_until, ewb_status, ewb_qr_payload, ewb_vehicle_number, ewb_transport_mode, ewb_transporter_name, ewb_transporter_id, ewb_distance_km, ewb_dispatch_address, ewb_ship_to_address, ewb_cancelled_at, ewb_cancel_reason, irn, irp_ack_number, irp_ack_date, irp_qr_payload, irp_status, irp_error, irp_error_code, irp_error_context, irp_cancelled_at, irp_cancel_reason, created_at, updated_at) FROM stdin;
1	1	POS-260609-0464	1	1	invoiced	2026-06-09	\N	2499.00	0.00	2499.00	2499.00	0.00	Channel: POS\nWalk-in: Naveen (8768686668)	2026-06-09 12:10:52.546+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-09 12:10:52.544664+00	2026-06-09 12:10:52.544664+00
2	1	POS-260609-7327	1	1	invoiced	2026-06-09	\N	2499.00	0.00	2499.00	2499.00	0.00	Channel: POS\nWalk-in: Siva (9042244200)	2026-06-09 12:31:14.84+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-09 12:31:14.83817+00	2026-06-09 12:31:14.83817+00
3	1	POS-260609-1958	1	1	invoiced	2026-06-09	\N	2499.00	0.00	2499.00	2499.00	0.00	Channel: POS\nWalk-in: Anand (9979877979)	2026-06-09 15:52:34.853+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-09 15:52:34.850695+00	2026-06-09 15:52:34.850695+00
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.session (sid, sess, expire) FROM stdin;
EES8w_1omgYn_byd9l3FKmmy3BD7wDpG	{"cookie":{"originalMaxAge":2592000000,"expires":"2026-07-09T15:54:36.488Z","secure":true,"httpOnly":true,"path":"/","sameSite":"none"},"userId":1}	2026-07-10 09:19:11
\.


--
-- Data for Name: shipment_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipment_lines (id, organization_id, shipment_id, sales_order_line_id, quantity) FROM stdin;
1	1	1	1	1.00
2	1	2	2	1.00
3	1	3	3	1.00
\.


--
-- Data for Name: shipments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipments (id, organization_id, sales_order_id, shipment_number, ship_date, status, notes, shiprocket_order_id, shiprocket_shipment_id, awb, courier_name, label_url, tracking_url, tracking_status, last_tracked_at, cancel_reason_code, cancel_reason_notes, cancelled_at, created_at, updated_at) FROM stdin;
1	1	1	POS-SHIP-260609-6277	2026-06-09	shipped	POS sale POS-260609-0464	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-09 12:10:52.544664+00	2026-06-09 12:10:52.544664+00
2	1	2	POS-SHIP-260609-5777	2026-06-09	shipped	POS sale POS-260609-7327	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-09 12:31:14.83817+00	2026-06-09 12:31:14.83817+00
3	1	3	POS-SHIP-260609-8322	2026-06-09	shipped	POS sale POS-260609-1958	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	2026-06-09 15:52:34.850695+00	2026-06-09 15:52:34.850695+00
\.


--
-- Data for Name: shopify_import_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shopify_import_jobs (id, organization_id, status, total, processed, imported, skipped, failed, failed_orders, from_date, to_date, error, started_at, finished_at) FROM stdin;
\.


--
-- Data for Name: shopify_oauth_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shopify_oauth_states (id, organization_id, state, shop_domain, created_at) FROM stdin;
\.


--
-- Data for Name: shopify_webhook_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shopify_webhook_events (id, organization_id, shopify_event_id, topic, received_at) FROM stdin;
\.


--
-- Data for Name: stock_batch_movements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_batch_movements (id, organization_id, stock_movement_id, item_batch_id, warehouse_id, quantity, created_at) FROM stdin;
\.


--
-- Data for Name: stock_movements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_movements (id, organization_id, item_id, warehouse_id, movement_type, quantity, reference_type, reference_id, notes, created_at) FROM stdin;
1	1	2	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
2	1	3	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
3	1	4	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
4	1	5	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
5	1	6	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
6	1	7	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
7	1	8	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
8	1	9	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
9	1	10	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
10	1	11	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
11	1	12	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
12	1	13	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
13	1	14	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
14	1	15	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
15	1	16	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
16	1	17	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
17	1	18	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
18	1	19	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
19	1	20	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
20	1	21	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
21	1	22	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
22	1	23	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
23	1	24	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
24	1	25	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
25	1	26	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
26	1	27	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
27	1	28	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
28	1	29	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
29	1	30	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
30	1	31	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
31	1	32	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
32	1	33	1	adjustment	50.00	\N	\N	Bulk import	2026-06-09 11:00:48.272458+00
33	1	2	1	sale	-1.00	pos_sale	1	POS sale POS-260609-0464	2026-06-09 12:10:52.544664+00
34	1	6	1	sale	-1.00	pos_sale	2	POS sale POS-260609-7327	2026-06-09 12:31:14.83817+00
35	1	35	1	opening	20.00	\N	\N	Opening stock (variant)	2026-06-09 13:47:41.326647+00
36	1	36	1	opening	10.00	\N	\N	Opening stock (variant)	2026-06-09 13:47:41.326647+00
37	1	37	1	opening	5.00	\N	\N	Opening stock (variant)	2026-06-09 13:47:41.326647+00
38	1	3	1	sale	-1.00	pos_sale	3	POS sale POS-260609-1958	2026-06-09 15:52:34.850695+00
39	1	23	1	transfer_out	-30.00	stock_transfer	2	Dispatched via transfer TRF-260609-2286	2026-06-09 15:58:38.707535+00
40	1	23	2	transfer_in	30.00	stock_transfer	2	Received via transfer TRF-260609-2286	2026-06-09 15:58:41.824287+00
41	1	38	1	adjustment	50.00	\N	\N	Unified bulk import	2026-06-09 18:01:27.352923+00
42	1	40	1	adjustment	30.00	\N	\N	Unified bulk import	2026-06-09 18:02:30.379707+00
43	1	41	1	adjustment	20.00	\N	\N	Unified bulk import	2026-06-09 18:02:30.379707+00
44	1	42	1	adjustment	50.00	\N	\N	Unified bulk import	2026-06-09 18:04:50.959382+00
45	1	44	1	adjustment	30.00	\N	\N	Unified bulk import	2026-06-09 18:04:50.959382+00
46	1	45	1	adjustment	20.00	\N	\N	Unified bulk import	2026-06-09 18:04:50.959382+00
47	1	46	1	adjustment	50.00	\N	\N	Unified bulk import	2026-06-09 18:10:17.996977+00
48	1	48	1	adjustment	30.00	\N	\N	Unified bulk import	2026-06-09 18:10:17.996977+00
49	1	49	1	adjustment	20.00	\N	\N	Unified bulk import	2026-06-09 18:10:17.996977+00
50	1	50	1	adjustment	50.00	\N	\N	Unified bulk import	2026-06-10 06:31:18.157933+00
51	1	52	1	adjustment	30.00	\N	\N	Unified bulk import	2026-06-10 06:31:18.157933+00
52	1	53	1	adjustment	20.00	\N	\N	Unified bulk import	2026-06-10 06:31:18.157933+00
\.


--
-- Data for Name: stock_transfer_lines; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_transfer_lines (id, organization_id, stock_transfer_id, item_id, quantity) FROM stdin;
1	1	1	29	100.00
2	1	2	23	30.00
\.


--
-- Data for Name: stock_transfers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_transfers (id, organization_id, transfer_number, from_warehouse_id, to_warehouse_id, transfer_date, status, notes, created_at, updated_at) FROM stdin;
1	1	TRF-260609-7948	1	2	2026-06-09	draft	\N	2026-06-09 15:58:00.867378+00	2026-06-09 15:58:00.867378+00
2	1	TRF-260609-2286	1	2	2026-06-09	completed	\N	2026-06-09 15:58:34.408483+00	2026-06-09 15:58:41.831+00
\.


--
-- Data for Name: supplier_payment_allocations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier_payment_allocations (id, organization_id, payment_id, purchase_order_id, amount) FROM stdin;
\.


--
-- Data for Name: supplier_payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.supplier_payments (id, organization_id, supplier_id, payment_date, amount, mode, reference_number, notes, bank_account_label, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.suppliers (id, organization_id, name, email, phone, company, gst_number, address, notes, outstanding_payable, is_job_worker, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: team_invitations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.team_invitations (id, organization_id, email, role, token, invited_by_user_id, expires_at, accepted_at, created_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, clerk_user_id, email, username, name, password_hash, email_verified_at, verify_token, verify_token_expires_at, reset_token, reset_token_expires_at, is_super_admin, created_at, updated_at) FROM stdin;
1	\N	anand@automystics.com	anand	anand	$2b$12$lPWCsioe0wMQTUy.oOeuRuFbCIxsP.xhqFUOR8gJvNK2.4mKqR1N.	2026-06-09 06:21:34.778+00	\N	\N	\N	\N	f	2026-06-09 06:21:34.77972+00	2026-06-09 06:22:58.497+00
2	\N	aa11@gmail.com	anand001	001	$2b$12$rCyxAZddDvAs4wq6yVtIKOQ0rzBrTpSPH6gpe9UTO0eziwt.iOnym	2026-06-09 13:17:59.89+00	\N	\N	\N	\N	f	2026-06-09 13:17:59.888156+00	2026-06-09 13:17:59.888156+00
\.


--
-- Data for Name: warehouses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.warehouses (id, organization_id, name, code, address_line1, city, state, country, is_default, is_virtual, job_worker_supplier_id, shopify_location_id, shopify_location_name, created_at, updated_at) FROM stdin;
1	1	Main Warehouse	MAIN	\N	\N	\N	India	t	f	\N	\N	\N	2026-06-09 06:22:58.517318+00	2026-06-09 06:22:58.517318+00
2	1	Store MMW	POS	\N	\N	\N	\N	f	f	\N	\N	\N	2026-06-09 15:57:21.657629+00	2026-06-09 15:57:21.657629+00
\.


--
-- Name: customer_payment_allocations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_payment_allocations_id_seq', 3, true);


--
-- Name: customer_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_payments_id_seq', 3, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 1, true);


--
-- Name: email_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.email_log_id_seq', 1, false);


--
-- Name: email_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.email_settings_id_seq', 1, false);


--
-- Name: goods_receipt_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.goods_receipt_lines_id_seq', 1, false);


--
-- Name: goods_receipts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.goods_receipts_id_seq', 1, false);


--
-- Name: item_batch_warehouse_stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_batch_warehouse_stock_id_seq', 1, false);


--
-- Name: item_batches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_batches_id_seq', 1, false);


--
-- Name: item_bundle_components_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_bundle_components_id_seq', 1, false);


--
-- Name: item_warehouse_stock_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.item_warehouse_stock_id_seq', 48, true);


--
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.items_id_seq', 53, true);


--
-- Name: job_work_issue_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_work_issue_lines_id_seq', 1, false);


--
-- Name: job_work_issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_work_issues_id_seq', 1, false);


--
-- Name: job_work_order_components_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_work_order_components_id_seq', 1, false);


--
-- Name: job_work_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_work_orders_id_seq', 1, false);


--
-- Name: job_work_receipt_components_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_work_receipt_components_id_seq', 1, false);


--
-- Name: job_work_receipts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_work_receipts_id_seq', 1, false);


--
-- Name: organization_members_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organization_members_id_seq', 2, true);


--
-- Name: organizations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.organizations_id_seq', 1, true);


--
-- Name: payment_links_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payment_links_id_seq', 1, false);


--
-- Name: print_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.print_log_id_seq', 6, true);


--
-- Name: purchase_order_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.purchase_order_lines_id_seq', 1, false);


--
-- Name: purchase_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.purchase_orders_id_seq', 1, false);


--
-- Name: sales_channel_warehouse_defaults_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_channel_warehouse_defaults_id_seq', 1, true);


--
-- Name: sales_order_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_order_lines_id_seq', 3, true);


--
-- Name: sales_orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sales_orders_id_seq', 3, true);


--
-- Name: shipment_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shipment_lines_id_seq', 3, true);


--
-- Name: shipments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shipments_id_seq', 3, true);


--
-- Name: shopify_oauth_states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shopify_oauth_states_id_seq', 1, false);


--
-- Name: shopify_webhook_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shopify_webhook_events_id_seq', 1, false);


--
-- Name: stock_batch_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_batch_movements_id_seq', 1, false);


--
-- Name: stock_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_movements_id_seq', 52, true);


--
-- Name: stock_transfer_lines_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_transfer_lines_id_seq', 2, true);


--
-- Name: stock_transfers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_transfers_id_seq', 2, true);


--
-- Name: supplier_payment_allocations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_payment_allocations_id_seq', 1, false);


--
-- Name: supplier_payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.supplier_payments_id_seq', 1, false);


--
-- Name: suppliers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.suppliers_id_seq', 1, false);


--
-- Name: team_invitations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.team_invitations_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: warehouses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.warehouses_id_seq', 2, true);


--
-- Name: customer_payment_allocations customer_payment_allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payment_allocations
    ADD CONSTRAINT customer_payment_allocations_pkey PRIMARY KEY (id);


--
-- Name: customer_payments customer_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: einvoice_bulk_batches einvoice_bulk_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.einvoice_bulk_batches
    ADD CONSTRAINT einvoice_bulk_batches_pkey PRIMARY KEY (id);


--
-- Name: email_log email_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_log
    ADD CONSTRAINT email_log_pkey PRIMARY KEY (id);


--
-- Name: email_settings email_settings_organization_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_settings
    ADD CONSTRAINT email_settings_organization_id_unique UNIQUE (organization_id);


--
-- Name: email_settings email_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_settings
    ADD CONSTRAINT email_settings_pkey PRIMARY KEY (id);


--
-- Name: goods_receipt_lines goods_receipt_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipt_lines
    ADD CONSTRAINT goods_receipt_lines_pkey PRIMARY KEY (id);


--
-- Name: goods_receipts goods_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipts
    ADD CONSTRAINT goods_receipts_pkey PRIMARY KEY (id);


--
-- Name: item_batch_warehouse_stock item_batch_warehouse_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batch_warehouse_stock
    ADD CONSTRAINT item_batch_warehouse_stock_pkey PRIMARY KEY (id);


--
-- Name: item_batches item_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batches
    ADD CONSTRAINT item_batches_pkey PRIMARY KEY (id);


--
-- Name: item_bundle_components item_bundle_components_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_bundle_components
    ADD CONSTRAINT item_bundle_components_pkey PRIMARY KEY (id);


--
-- Name: item_warehouse_stock item_warehouse_stock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_warehouse_stock
    ADD CONSTRAINT item_warehouse_stock_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: job_work_issue_lines job_work_issue_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issue_lines
    ADD CONSTRAINT job_work_issue_lines_pkey PRIMARY KEY (id);


--
-- Name: job_work_issues job_work_issues_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issues
    ADD CONSTRAINT job_work_issues_pkey PRIMARY KEY (id);


--
-- Name: job_work_order_components job_work_order_components_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_order_components
    ADD CONSTRAINT job_work_order_components_pkey PRIMARY KEY (id);


--
-- Name: job_work_orders job_work_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_orders
    ADD CONSTRAINT job_work_orders_pkey PRIMARY KEY (id);


--
-- Name: job_work_receipt_components job_work_receipt_components_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipt_components
    ADD CONSTRAINT job_work_receipt_components_pkey PRIMARY KEY (id);


--
-- Name: job_work_receipts job_work_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipts
    ADD CONSTRAINT job_work_receipts_pkey PRIMARY KEY (id);


--
-- Name: organization_members organization_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: payment_links payment_links_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_links
    ADD CONSTRAINT payment_links_pkey PRIMARY KEY (id);


--
-- Name: print_log print_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.print_log
    ADD CONSTRAINT print_log_pkey PRIMARY KEY (id);


--
-- Name: purchase_order_lines purchase_order_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_lines
    ADD CONSTRAINT purchase_order_lines_pkey PRIMARY KEY (id);


--
-- Name: purchase_orders purchase_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);


--
-- Name: sales_channel_warehouse_defaults sales_channel_warehouse_defaults_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_channel_warehouse_defaults
    ADD CONSTRAINT sales_channel_warehouse_defaults_pkey PRIMARY KEY (id);


--
-- Name: sales_order_lines sales_order_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_order_lines
    ADD CONSTRAINT sales_order_lines_pkey PRIMARY KEY (id);


--
-- Name: sales_orders sales_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sid);


--
-- Name: shipment_lines shipment_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_lines
    ADD CONSTRAINT shipment_lines_pkey PRIMARY KEY (id);


--
-- Name: shipments shipments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_pkey PRIMARY KEY (id);


--
-- Name: shopify_import_jobs shopify_import_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopify_import_jobs
    ADD CONSTRAINT shopify_import_jobs_pkey PRIMARY KEY (id);


--
-- Name: shopify_oauth_states shopify_oauth_states_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopify_oauth_states
    ADD CONSTRAINT shopify_oauth_states_pkey PRIMARY KEY (id);


--
-- Name: shopify_webhook_events shopify_webhook_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopify_webhook_events
    ADD CONSTRAINT shopify_webhook_events_pkey PRIMARY KEY (id);


--
-- Name: stock_batch_movements stock_batch_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_batch_movements
    ADD CONSTRAINT stock_batch_movements_pkey PRIMARY KEY (id);


--
-- Name: stock_movements stock_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_pkey PRIMARY KEY (id);


--
-- Name: stock_transfer_lines stock_transfer_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfer_lines
    ADD CONSTRAINT stock_transfer_lines_pkey PRIMARY KEY (id);


--
-- Name: stock_transfers stock_transfers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_pkey PRIMARY KEY (id);


--
-- Name: supplier_payment_allocations supplier_payment_allocations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payment_allocations
    ADD CONSTRAINT supplier_payment_allocations_pkey PRIMARY KEY (id);


--
-- Name: supplier_payments supplier_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_pkey PRIMARY KEY (id);


--
-- Name: suppliers suppliers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);


--
-- Name: team_invitations team_invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: warehouses warehouses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_pkey PRIMARY KEY (id);


--
-- Name: IDX_session_expire; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_session_expire" ON public.session USING btree (expire);


--
-- Name: customer_payment_allocations_org_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX customer_payment_allocations_org_idx ON public.customer_payment_allocations USING btree (organization_id);


--
-- Name: customer_payment_allocations_payment_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX customer_payment_allocations_payment_idx ON public.customer_payment_allocations USING btree (payment_id);


--
-- Name: customer_payment_allocations_so_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX customer_payment_allocations_so_idx ON public.customer_payment_allocations USING btree (sales_order_id);


--
-- Name: customer_payments_org_customer_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX customer_payments_org_customer_idx ON public.customer_payments USING btree (organization_id, customer_id);


--
-- Name: customer_payments_org_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX customer_payments_org_date_idx ON public.customer_payments USING btree (organization_id, payment_date);


--
-- Name: einvoice_bulk_batches_org_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX einvoice_bulk_batches_org_idx ON public.einvoice_bulk_batches USING btree (organization_id);


--
-- Name: einvoice_bulk_batches_status_created_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX einvoice_bulk_batches_status_created_idx ON public.einvoice_bulk_batches USING btree (status, created_at);


--
-- Name: email_log_org_sales_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX email_log_org_sales_order_idx ON public.email_log USING btree (organization_id, sales_order_id);


--
-- Name: goods_receipt_lines_org_line_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX goods_receipt_lines_org_line_idx ON public.goods_receipt_lines USING btree (organization_id, purchase_order_line_id);


--
-- Name: goods_receipt_lines_receipt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX goods_receipt_lines_receipt_idx ON public.goods_receipt_lines USING btree (goods_receipt_id);


--
-- Name: goods_receipts_org_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX goods_receipts_org_number_idx ON public.goods_receipts USING btree (organization_id, receipt_number);


--
-- Name: goods_receipts_org_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX goods_receipts_org_order_idx ON public.goods_receipts USING btree (organization_id, purchase_order_id);


--
-- Name: item_batch_wh_stock_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX item_batch_wh_stock_idx ON public.item_batch_warehouse_stock USING btree (item_batch_id, warehouse_id);


--
-- Name: item_batch_wh_stock_wh_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX item_batch_wh_stock_wh_idx ON public.item_batch_warehouse_stock USING btree (warehouse_id);


--
-- Name: item_batches_item_batchno_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX item_batches_item_batchno_idx ON public.item_batches USING btree (item_id, batch_number);


--
-- Name: item_batches_org_expiry_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX item_batches_org_expiry_idx ON public.item_batches USING btree (organization_id, expiry_date);


--
-- Name: item_batches_org_item_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX item_batches_org_item_idx ON public.item_batches USING btree (organization_id, item_id);


--
-- Name: item_bundle_components_org_comp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX item_bundle_components_org_comp_idx ON public.item_bundle_components USING btree (organization_id, component_item_id);


--
-- Name: item_bundle_components_org_parent_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX item_bundle_components_org_parent_idx ON public.item_bundle_components USING btree (organization_id, parent_item_id);


--
-- Name: item_bundle_components_parent_comp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX item_bundle_components_parent_comp_idx ON public.item_bundle_components USING btree (parent_item_id, component_item_id);


--
-- Name: item_warehouse_stock_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX item_warehouse_stock_idx ON public.item_warehouse_stock USING btree (item_id, warehouse_id);


--
-- Name: items_org_barcode_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX items_org_barcode_idx ON public.items USING btree (organization_id, barcode);


--
-- Name: items_org_barcode_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX items_org_barcode_unique_idx ON public.items USING btree (organization_id, barcode) WHERE ((barcode IS NOT NULL) AND (archived_at IS NULL));


--
-- Name: items_org_parent_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX items_org_parent_idx ON public.items USING btree (organization_id, parent_item_id);


--
-- Name: items_org_shopify_variant_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX items_org_shopify_variant_idx ON public.items USING btree (organization_id, shopify_variant_id);


--
-- Name: items_org_sku_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX items_org_sku_idx ON public.items USING btree (organization_id, sku) WHERE (archived_at IS NULL);


--
-- Name: job_work_issue_lines_issue_comp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX job_work_issue_lines_issue_comp_idx ON public.job_work_issue_lines USING btree (job_work_issue_id, component_item_id);


--
-- Name: job_work_issue_lines_issue_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX job_work_issue_lines_issue_idx ON public.job_work_issue_lines USING btree (job_work_issue_id);


--
-- Name: job_work_issues_jwo_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX job_work_issues_jwo_idx ON public.job_work_issues USING btree (job_work_order_id);


--
-- Name: job_work_issues_org_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX job_work_issues_org_number_idx ON public.job_work_issues USING btree (organization_id, issue_number);


--
-- Name: job_work_order_components_jwo_comp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX job_work_order_components_jwo_comp_idx ON public.job_work_order_components USING btree (job_work_order_id, component_item_id);


--
-- Name: job_work_order_components_org_jwo_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX job_work_order_components_org_jwo_idx ON public.job_work_order_components USING btree (organization_id, job_work_order_id);


--
-- Name: job_work_orders_org_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX job_work_orders_org_number_idx ON public.job_work_orders USING btree (organization_id, jwo_number);


--
-- Name: job_work_orders_org_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX job_work_orders_org_status_idx ON public.job_work_orders USING btree (organization_id, status);


--
-- Name: job_work_orders_org_supplier_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX job_work_orders_org_supplier_idx ON public.job_work_orders USING btree (organization_id, supplier_id);


--
-- Name: job_work_receipt_components_receipt_comp_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX job_work_receipt_components_receipt_comp_idx ON public.job_work_receipt_components USING btree (job_work_receipt_id, component_item_id);


--
-- Name: job_work_receipt_components_receipt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX job_work_receipt_components_receipt_idx ON public.job_work_receipt_components USING btree (job_work_receipt_id);


--
-- Name: job_work_receipts_jwo_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX job_work_receipts_jwo_idx ON public.job_work_receipts USING btree (job_work_order_id);


--
-- Name: job_work_receipts_org_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX job_work_receipts_org_number_idx ON public.job_work_receipts USING btree (organization_id, receipt_number);


--
-- Name: org_members_user_org_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX org_members_user_org_idx ON public.organization_members USING btree (user_id, organization_id);


--
-- Name: organizations_slug_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX organizations_slug_idx ON public.organizations USING btree (slug);


--
-- Name: payment_links_active_unique_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX payment_links_active_unique_idx ON public.payment_links USING btree (organization_id, sales_order_id) WHERE (status = 'created'::text);


--
-- Name: payment_links_org_sales_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX payment_links_org_sales_order_idx ON public.payment_links USING btree (organization_id, sales_order_id);


--
-- Name: payment_links_razorpay_link_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX payment_links_razorpay_link_id_idx ON public.payment_links USING btree (razorpay_link_id);


--
-- Name: payment_links_razorpay_payment_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX payment_links_razorpay_payment_id_idx ON public.payment_links USING btree (razorpay_payment_id);


--
-- Name: purchase_orders_org_jw_receipt_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX purchase_orders_org_jw_receipt_idx ON public.purchase_orders USING btree (organization_id, job_work_receipt_id);


--
-- Name: purchase_orders_org_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX purchase_orders_org_number_idx ON public.purchase_orders USING btree (organization_id, order_number);


--
-- Name: sales_channel_defaults_org_channel_wh_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sales_channel_defaults_org_channel_wh_idx ON public.sales_channel_warehouse_defaults USING btree (organization_id, sales_channel, warehouse_id);


--
-- Name: sales_orders_org_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sales_orders_org_number_idx ON public.sales_orders USING btree (organization_id, order_number);


--
-- Name: sales_orders_org_shopify_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX sales_orders_org_shopify_order_idx ON public.sales_orders USING btree (organization_id, shopify_order_id);


--
-- Name: shipment_lines_org_line_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shipment_lines_org_line_idx ON public.shipment_lines USING btree (organization_id, sales_order_line_id);


--
-- Name: shipment_lines_shipment_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shipment_lines_shipment_idx ON public.shipment_lines USING btree (shipment_id);


--
-- Name: shipments_org_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX shipments_org_number_idx ON public.shipments USING btree (organization_id, shipment_number);


--
-- Name: shipments_org_order_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shipments_org_order_idx ON public.shipments USING btree (organization_id, sales_order_id);


--
-- Name: shopify_import_jobs_finished_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shopify_import_jobs_finished_at_idx ON public.shopify_import_jobs USING btree (finished_at);


--
-- Name: shopify_import_jobs_org_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX shopify_import_jobs_org_idx ON public.shopify_import_jobs USING btree (organization_id);


--
-- Name: shopify_oauth_states_state_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX shopify_oauth_states_state_idx ON public.shopify_oauth_states USING btree (state);


--
-- Name: shopify_webhook_events_org_event_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX shopify_webhook_events_org_event_idx ON public.shopify_webhook_events USING btree (organization_id, shopify_event_id);


--
-- Name: stock_batch_mvts_batch_wh_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stock_batch_mvts_batch_wh_idx ON public.stock_batch_movements USING btree (item_batch_id, warehouse_id);


--
-- Name: stock_batch_mvts_movement_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stock_batch_mvts_movement_idx ON public.stock_batch_movements USING btree (stock_movement_id);


--
-- Name: stock_batch_mvts_org_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stock_batch_mvts_org_idx ON public.stock_batch_movements USING btree (organization_id);


--
-- Name: stock_transfer_lines_org_item_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stock_transfer_lines_org_item_idx ON public.stock_transfer_lines USING btree (organization_id, item_id);


--
-- Name: stock_transfer_lines_transfer_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stock_transfer_lines_transfer_idx ON public.stock_transfer_lines USING btree (stock_transfer_id);


--
-- Name: stock_transfers_org_from_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stock_transfers_org_from_idx ON public.stock_transfers USING btree (organization_id, from_warehouse_id);


--
-- Name: stock_transfers_org_number_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX stock_transfers_org_number_idx ON public.stock_transfers USING btree (organization_id, transfer_number);


--
-- Name: stock_transfers_org_status_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stock_transfers_org_status_idx ON public.stock_transfers USING btree (organization_id, status);


--
-- Name: stock_transfers_org_to_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX stock_transfers_org_to_idx ON public.stock_transfers USING btree (organization_id, to_warehouse_id);


--
-- Name: supplier_payment_allocations_org_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX supplier_payment_allocations_org_idx ON public.supplier_payment_allocations USING btree (organization_id);


--
-- Name: supplier_payment_allocations_payment_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX supplier_payment_allocations_payment_idx ON public.supplier_payment_allocations USING btree (payment_id);


--
-- Name: supplier_payment_allocations_po_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX supplier_payment_allocations_po_idx ON public.supplier_payment_allocations USING btree (purchase_order_id);


--
-- Name: supplier_payments_org_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX supplier_payments_org_date_idx ON public.supplier_payments USING btree (organization_id, payment_date);


--
-- Name: supplier_payments_org_supplier_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX supplier_payments_org_supplier_idx ON public.supplier_payments USING btree (organization_id, supplier_id);


--
-- Name: team_invitations_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX team_invitations_token_idx ON public.team_invitations USING btree (token);


--
-- Name: users_clerk_user_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_clerk_user_id_idx ON public.users USING btree (clerk_user_id);


--
-- Name: users_email_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_email_idx ON public.users USING btree (email);


--
-- Name: users_reset_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_reset_token_idx ON public.users USING btree (reset_token);


--
-- Name: users_username_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_username_idx ON public.users USING btree (username);


--
-- Name: users_verify_token_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_verify_token_idx ON public.users USING btree (verify_token);


--
-- Name: warehouses_org_code_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX warehouses_org_code_idx ON public.warehouses USING btree (organization_id, code);


--
-- Name: warehouses_org_job_worker_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX warehouses_org_job_worker_idx ON public.warehouses USING btree (organization_id, job_worker_supplier_id) WHERE (is_virtual = true);


--
-- Name: warehouses_org_shopify_location_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX warehouses_org_shopify_location_idx ON public.warehouses USING btree (organization_id, shopify_location_id) WHERE (shopify_location_id IS NOT NULL);


--
-- Name: customer_payment_allocations customer_payment_allocations_organization_id_organizations_id_f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payment_allocations
    ADD CONSTRAINT customer_payment_allocations_organization_id_organizations_id_f FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: customer_payment_allocations customer_payment_allocations_payment_id_customer_payments_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payment_allocations
    ADD CONSTRAINT customer_payment_allocations_payment_id_customer_payments_id_fk FOREIGN KEY (payment_id) REFERENCES public.customer_payments(id) ON DELETE CASCADE;


--
-- Name: customer_payment_allocations customer_payment_allocations_sales_order_id_sales_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payment_allocations
    ADD CONSTRAINT customer_payment_allocations_sales_order_id_sales_orders_id_fk FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE RESTRICT;


--
-- Name: customer_payments customer_payments_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: customer_payments customer_payments_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_payments
    ADD CONSTRAINT customer_payments_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: customers customers_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: einvoice_bulk_batches einvoice_bulk_batches_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.einvoice_bulk_batches
    ADD CONSTRAINT einvoice_bulk_batches_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: email_log email_log_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_log
    ADD CONSTRAINT email_log_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: email_log email_log_sales_order_id_sales_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_log
    ADD CONSTRAINT email_log_sales_order_id_sales_orders_id_fk FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE SET NULL;


--
-- Name: email_log email_log_sent_by_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_log
    ADD CONSTRAINT email_log_sent_by_user_id_users_id_fk FOREIGN KEY (sent_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: email_settings email_settings_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_settings
    ADD CONSTRAINT email_settings_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: goods_receipt_lines goods_receipt_lines_goods_receipt_id_goods_receipts_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipt_lines
    ADD CONSTRAINT goods_receipt_lines_goods_receipt_id_goods_receipts_id_fk FOREIGN KEY (goods_receipt_id) REFERENCES public.goods_receipts(id) ON DELETE CASCADE;


--
-- Name: goods_receipt_lines goods_receipt_lines_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipt_lines
    ADD CONSTRAINT goods_receipt_lines_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: goods_receipt_lines goods_receipt_lines_purchase_order_line_id_purchase_order_lines; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipt_lines
    ADD CONSTRAINT goods_receipt_lines_purchase_order_line_id_purchase_order_lines FOREIGN KEY (purchase_order_line_id) REFERENCES public.purchase_order_lines(id) ON DELETE RESTRICT;


--
-- Name: goods_receipts goods_receipts_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipts
    ADD CONSTRAINT goods_receipts_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: goods_receipts goods_receipts_purchase_order_id_purchase_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.goods_receipts
    ADD CONSTRAINT goods_receipts_purchase_order_id_purchase_orders_id_fk FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id) ON DELETE CASCADE;


--
-- Name: item_batch_warehouse_stock item_batch_warehouse_stock_item_batch_id_item_batches_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batch_warehouse_stock
    ADD CONSTRAINT item_batch_warehouse_stock_item_batch_id_item_batches_id_fk FOREIGN KEY (item_batch_id) REFERENCES public.item_batches(id) ON DELETE CASCADE;


--
-- Name: item_batch_warehouse_stock item_batch_warehouse_stock_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batch_warehouse_stock
    ADD CONSTRAINT item_batch_warehouse_stock_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: item_batch_warehouse_stock item_batch_warehouse_stock_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batch_warehouse_stock
    ADD CONSTRAINT item_batch_warehouse_stock_warehouse_id_warehouses_id_fk FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: item_batches item_batches_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batches
    ADD CONSTRAINT item_batches_item_id_items_id_fk FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: item_batches item_batches_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_batches
    ADD CONSTRAINT item_batches_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: item_bundle_components item_bundle_components_component_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_bundle_components
    ADD CONSTRAINT item_bundle_components_component_item_id_items_id_fk FOREIGN KEY (component_item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: item_bundle_components item_bundle_components_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_bundle_components
    ADD CONSTRAINT item_bundle_components_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: item_bundle_components item_bundle_components_parent_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_bundle_components
    ADD CONSTRAINT item_bundle_components_parent_item_id_items_id_fk FOREIGN KEY (parent_item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: item_warehouse_stock item_warehouse_stock_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_warehouse_stock
    ADD CONSTRAINT item_warehouse_stock_item_id_items_id_fk FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: item_warehouse_stock item_warehouse_stock_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_warehouse_stock
    ADD CONSTRAINT item_warehouse_stock_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: item_warehouse_stock item_warehouse_stock_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.item_warehouse_stock
    ADD CONSTRAINT item_warehouse_stock_warehouse_id_warehouses_id_fk FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: items items_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: items items_parent_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_parent_item_id_items_id_fk FOREIGN KEY (parent_item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: job_work_issue_lines job_work_issue_lines_component_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issue_lines
    ADD CONSTRAINT job_work_issue_lines_component_item_id_items_id_fk FOREIGN KEY (component_item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: job_work_issue_lines job_work_issue_lines_job_work_issue_id_job_work_issues_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issue_lines
    ADD CONSTRAINT job_work_issue_lines_job_work_issue_id_job_work_issues_id_fk FOREIGN KEY (job_work_issue_id) REFERENCES public.job_work_issues(id) ON DELETE CASCADE;


--
-- Name: job_work_issue_lines job_work_issue_lines_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issue_lines
    ADD CONSTRAINT job_work_issue_lines_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: job_work_issues job_work_issues_job_work_order_id_job_work_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issues
    ADD CONSTRAINT job_work_issues_job_work_order_id_job_work_orders_id_fk FOREIGN KEY (job_work_order_id) REFERENCES public.job_work_orders(id) ON DELETE CASCADE;


--
-- Name: job_work_issues job_work_issues_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_issues
    ADD CONSTRAINT job_work_issues_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: job_work_order_components job_work_order_components_component_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_order_components
    ADD CONSTRAINT job_work_order_components_component_item_id_items_id_fk FOREIGN KEY (component_item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: job_work_order_components job_work_order_components_job_work_order_id_job_work_orders_id_; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_order_components
    ADD CONSTRAINT job_work_order_components_job_work_order_id_job_work_orders_id_ FOREIGN KEY (job_work_order_id) REFERENCES public.job_work_orders(id) ON DELETE CASCADE;


--
-- Name: job_work_order_components job_work_order_components_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_order_components
    ADD CONSTRAINT job_work_order_components_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: job_work_orders job_work_orders_dest_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_orders
    ADD CONSTRAINT job_work_orders_dest_warehouse_id_warehouses_id_fk FOREIGN KEY (dest_warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: job_work_orders job_work_orders_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_orders
    ADD CONSTRAINT job_work_orders_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: job_work_orders job_work_orders_output_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_orders
    ADD CONSTRAINT job_work_orders_output_item_id_items_id_fk FOREIGN KEY (output_item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: job_work_orders job_work_orders_source_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_orders
    ADD CONSTRAINT job_work_orders_source_warehouse_id_warehouses_id_fk FOREIGN KEY (source_warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: job_work_orders job_work_orders_supplier_id_suppliers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_orders
    ADD CONSTRAINT job_work_orders_supplier_id_suppliers_id_fk FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE RESTRICT;


--
-- Name: job_work_orders job_work_orders_vendor_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_orders
    ADD CONSTRAINT job_work_orders_vendor_warehouse_id_warehouses_id_fk FOREIGN KEY (vendor_warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: job_work_receipt_components job_work_receipt_components_component_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipt_components
    ADD CONSTRAINT job_work_receipt_components_component_item_id_items_id_fk FOREIGN KEY (component_item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: job_work_receipt_components job_work_receipt_components_job_work_receipt_id_job_work_receip; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipt_components
    ADD CONSTRAINT job_work_receipt_components_job_work_receipt_id_job_work_receip FOREIGN KEY (job_work_receipt_id) REFERENCES public.job_work_receipts(id) ON DELETE CASCADE;


--
-- Name: job_work_receipt_components job_work_receipt_components_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipt_components
    ADD CONSTRAINT job_work_receipt_components_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: job_work_receipts job_work_receipts_job_work_order_id_job_work_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipts
    ADD CONSTRAINT job_work_receipts_job_work_order_id_job_work_orders_id_fk FOREIGN KEY (job_work_order_id) REFERENCES public.job_work_orders(id) ON DELETE CASCADE;


--
-- Name: job_work_receipts job_work_receipts_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_work_receipts
    ADD CONSTRAINT job_work_receipts_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_members organization_members_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_members organization_members_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: payment_links payment_links_created_by_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_links
    ADD CONSTRAINT payment_links_created_by_user_id_users_id_fk FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: payment_links payment_links_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_links
    ADD CONSTRAINT payment_links_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: payment_links payment_links_sales_order_id_sales_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_links
    ADD CONSTRAINT payment_links_sales_order_id_sales_orders_id_fk FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE CASCADE;


--
-- Name: print_log print_log_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.print_log
    ADD CONSTRAINT print_log_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: print_log print_log_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.print_log
    ADD CONSTRAINT print_log_user_id_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: purchase_order_lines purchase_order_lines_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_lines
    ADD CONSTRAINT purchase_order_lines_item_id_items_id_fk FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: purchase_order_lines purchase_order_lines_purchase_order_id_purchase_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_order_lines
    ADD CONSTRAINT purchase_order_lines_purchase_order_id_purchase_orders_id_fk FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id) ON DELETE CASCADE;


--
-- Name: purchase_orders purchase_orders_job_work_receipt_id_job_work_receipts_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_job_work_receipt_id_job_work_receipts_id_fk FOREIGN KEY (job_work_receipt_id) REFERENCES public.job_work_receipts(id) ON DELETE SET NULL;


--
-- Name: purchase_orders purchase_orders_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: purchase_orders purchase_orders_supplier_id_suppliers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_supplier_id_suppliers_id_fk FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE RESTRICT;


--
-- Name: purchase_orders purchase_orders_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_warehouse_id_warehouses_id_fk FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: sales_channel_warehouse_defaults sales_channel_warehouse_defaults_organization_id_organizations_; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_channel_warehouse_defaults
    ADD CONSTRAINT sales_channel_warehouse_defaults_organization_id_organizations_ FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: sales_channel_warehouse_defaults sales_channel_warehouse_defaults_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_channel_warehouse_defaults
    ADD CONSTRAINT sales_channel_warehouse_defaults_warehouse_id_warehouses_id_fk FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: sales_order_lines sales_order_lines_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_order_lines
    ADD CONSTRAINT sales_order_lines_item_id_items_id_fk FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: sales_order_lines sales_order_lines_sales_order_id_sales_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_order_lines
    ADD CONSTRAINT sales_order_lines_sales_order_id_sales_orders_id_fk FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE CASCADE;


--
-- Name: sales_orders sales_orders_customer_id_customers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_customer_id_customers_id_fk FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE RESTRICT;


--
-- Name: sales_orders sales_orders_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: sales_orders sales_orders_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_warehouse_id_warehouses_id_fk FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: shipment_lines shipment_lines_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_lines
    ADD CONSTRAINT shipment_lines_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: shipment_lines shipment_lines_sales_order_line_id_sales_order_lines_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_lines
    ADD CONSTRAINT shipment_lines_sales_order_line_id_sales_order_lines_id_fk FOREIGN KEY (sales_order_line_id) REFERENCES public.sales_order_lines(id) ON DELETE RESTRICT;


--
-- Name: shipment_lines shipment_lines_shipment_id_shipments_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipment_lines
    ADD CONSTRAINT shipment_lines_shipment_id_shipments_id_fk FOREIGN KEY (shipment_id) REFERENCES public.shipments(id) ON DELETE CASCADE;


--
-- Name: shipments shipments_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: shipments shipments_sales_order_id_sales_orders_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipments
    ADD CONSTRAINT shipments_sales_order_id_sales_orders_id_fk FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id) ON DELETE CASCADE;


--
-- Name: shopify_import_jobs shopify_import_jobs_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopify_import_jobs
    ADD CONSTRAINT shopify_import_jobs_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: shopify_oauth_states shopify_oauth_states_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopify_oauth_states
    ADD CONSTRAINT shopify_oauth_states_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: shopify_webhook_events shopify_webhook_events_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopify_webhook_events
    ADD CONSTRAINT shopify_webhook_events_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: stock_batch_movements stock_batch_movements_item_batch_id_item_batches_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_batch_movements
    ADD CONSTRAINT stock_batch_movements_item_batch_id_item_batches_id_fk FOREIGN KEY (item_batch_id) REFERENCES public.item_batches(id) ON DELETE RESTRICT;


--
-- Name: stock_batch_movements stock_batch_movements_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_batch_movements
    ADD CONSTRAINT stock_batch_movements_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: stock_batch_movements stock_batch_movements_stock_movement_id_stock_movements_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_batch_movements
    ADD CONSTRAINT stock_batch_movements_stock_movement_id_stock_movements_id_fk FOREIGN KEY (stock_movement_id) REFERENCES public.stock_movements(id) ON DELETE CASCADE;


--
-- Name: stock_batch_movements stock_batch_movements_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_batch_movements
    ADD CONSTRAINT stock_batch_movements_warehouse_id_warehouses_id_fk FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: stock_movements stock_movements_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_item_id_items_id_fk FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE CASCADE;


--
-- Name: stock_movements stock_movements_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: stock_movements stock_movements_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_warehouse_id_warehouses_id_fk FOREIGN KEY (warehouse_id) REFERENCES public.warehouses(id) ON DELETE CASCADE;


--
-- Name: stock_transfer_lines stock_transfer_lines_item_id_items_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfer_lines
    ADD CONSTRAINT stock_transfer_lines_item_id_items_id_fk FOREIGN KEY (item_id) REFERENCES public.items(id) ON DELETE RESTRICT;


--
-- Name: stock_transfer_lines stock_transfer_lines_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfer_lines
    ADD CONSTRAINT stock_transfer_lines_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: stock_transfer_lines stock_transfer_lines_stock_transfer_id_stock_transfers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfer_lines
    ADD CONSTRAINT stock_transfer_lines_stock_transfer_id_stock_transfers_id_fk FOREIGN KEY (stock_transfer_id) REFERENCES public.stock_transfers(id) ON DELETE CASCADE;


--
-- Name: stock_transfers stock_transfers_from_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_from_warehouse_id_warehouses_id_fk FOREIGN KEY (from_warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: stock_transfers stock_transfers_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: stock_transfers stock_transfers_to_warehouse_id_warehouses_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_to_warehouse_id_warehouses_id_fk FOREIGN KEY (to_warehouse_id) REFERENCES public.warehouses(id) ON DELETE RESTRICT;


--
-- Name: supplier_payment_allocations supplier_payment_allocations_organization_id_organizations_id_f; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payment_allocations
    ADD CONSTRAINT supplier_payment_allocations_organization_id_organizations_id_f FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: supplier_payment_allocations supplier_payment_allocations_payment_id_supplier_payments_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payment_allocations
    ADD CONSTRAINT supplier_payment_allocations_payment_id_supplier_payments_id_fk FOREIGN KEY (payment_id) REFERENCES public.supplier_payments(id) ON DELETE CASCADE;


--
-- Name: supplier_payment_allocations supplier_payment_allocations_purchase_order_id_purchase_orders_; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payment_allocations
    ADD CONSTRAINT supplier_payment_allocations_purchase_order_id_purchase_orders_ FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id) ON DELETE RESTRICT;


--
-- Name: supplier_payments supplier_payments_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: supplier_payments supplier_payments_supplier_id_suppliers_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_supplier_id_suppliers_id_fk FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE RESTRICT;


--
-- Name: suppliers suppliers_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: team_invitations team_invitations_invited_by_user_id_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_invited_by_user_id_users_id_fk FOREIGN KEY (invited_by_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: team_invitations team_invitations_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team_invitations
    ADD CONSTRAINT team_invitations_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: warehouses warehouses_organization_id_organizations_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.warehouses
    ADD CONSTRAINT warehouses_organization_id_organizations_id_fk FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict jHdHSxXu8PAQNtnDz9CF3Cu3EwUaHNSDkSirqSsKtP4B9egEU0yhSGchcVZuppj

