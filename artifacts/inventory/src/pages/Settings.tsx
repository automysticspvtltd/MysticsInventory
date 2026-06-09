import { PageHeader } from "@/components/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage, FormDescription } from "@/components/ui/form";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { Textarea } from "@/components/ui/textarea";
import {
  useGetCurrentOrganization,
  useUpdateCurrentOrganization,
  getGetCurrentOrganizationQueryKey,
  useUpdateOrganizationBarcodeSettings,
  useListSalesChannelDefaults,
  useSetSalesChannelDefault,
  useListWarehouses,
} from "@/lib/queryKeys";
import { useQueryClient } from "@tanstack/react-query";
import { useToast } from "@/hooks/use-toast";
import { useEffect, useRef, useState } from "react";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Building2, FileCheck2, ChevronRight, ScanLine, ShoppingCart, Store, Plus, X, ImageIcon } from "lucide-react";
import { Link } from "wouter";
import { ImageUploader } from "@/components/ImageUploader";

const orgSchema = z.object({
  name: z.string().min(1, "Organization name is required"),
  currency: z.string().min(3),
  timezone: z.string().min(1),
  gstNumber: z.string().optional().or(z.literal("")),
  addressLine1: z.string().optional().or(z.literal("")),
  city: z.string().optional().or(z.literal("")),
  state: z.string().optional().or(z.literal("")),
  postalCode: z.string().optional().or(z.literal("")),
  country: z.string().optional().or(z.literal("")),
  // Either an uploaded object-storage path (`/objects/uploads/<id>`) or a full
  // https URL (e.g. a Shopify CDN logo synced in from elsewhere).
  logoUrl: z
    .string()
    .refine(
      (v) => v === "" || v.startsWith("/objects/") || /^https?:\/\//i.test(v),
      "Must be an uploaded image or a valid URL",
    )
    .optional()
    .or(z.literal("")),
  invoiceFooter: z.string().optional().or(z.literal("")),
});

type OrgFormValues = z.infer<typeof orgSchema>;

export default function Settings() {
  const { data: org, isLoading } = useGetCurrentOrganization();
  const queryClient = useQueryClient();
  const { toast } = useToast();

  const updateMutation = useUpdateCurrentOrganization({
    mutation: {
      onSuccess: () => {
        queryClient.invalidateQueries({ queryKey: getGetCurrentOrganizationQueryKey() });
        toast({ title: "Settings saved successfully" });
      }
    }
  });

  const form = useForm<OrgFormValues>({
    resolver: zodResolver(orgSchema),
    defaultValues: {
      name: "",
      currency: "INR",
      timezone: "Asia/Kolkata",
      gstNumber: "",
      addressLine1: "",
      city: "",
      state: "",
      postalCode: "",
      country: "India",
      logoUrl: "",
      invoiceFooter: "",
    }
  });

  useEffect(() => {
    if (org) {
      form.reset({
        name: org.name,
        currency: org.currency,
        timezone: org.timezone,
        gstNumber: org.gstNumber || "",
        addressLine1: org.addressLine1 || "",
        city: org.city || "",
        state: org.state || "",
        postalCode: org.postalCode || "",
        country: org.country || "India",
        logoUrl: org.logoUrl || "",
        invoiceFooter: org.invoiceFooter || "",
      });
    }
  }, [org, form]);

  const onSubmit = (data: OrgFormValues) => {
    updateMutation.mutate({
      data: {
        ...data,
        gstNumber: data.gstNumber || null,
        addressLine1: data.addressLine1 || null,
        city: data.city || null,
        state: data.state || null,
        postalCode: data.postalCode || null,
        country: data.country || null,
        logoUrl: data.logoUrl || null,
        invoiceFooter: data.invoiceFooter || null,
      }
    });
  };

  if (isLoading) return null;

  return (
    <div className="space-y-6 max-w-3xl">
      <PageHeader 
        title="Settings" 
        description="Manage your organization profile and preferences."
      />

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Building2 className="h-5 w-5 text-primary" />
            Organization Profile
          </CardTitle>
          <CardDescription>
            These details appear on your invoices and purchase orders.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
              <div className="grid md:grid-cols-2 gap-6">
                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Organization Name *</FormLabel>
                      <FormControl>
                        <Input {...field} data-testid="input-org-name" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="gstNumber"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>GST Number</FormLabel>
                      <FormControl>
                        <Input {...field} data-testid="input-org-gst" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <div className="grid md:grid-cols-2 gap-6">
                <FormField
                  control={form.control}
                  name="currency"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Base Currency</FormLabel>
                      <Select onValueChange={field.onChange} value={field.value}>
                        <FormControl>
                          <SelectTrigger data-testid="select-org-currency">
                            <SelectValue placeholder="Select currency" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="INR">Indian Rupee (₹)</SelectItem>
                          <SelectItem value="USD">US Dollar ($)</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormDescription>Your reporting currency.</FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="timezone"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Timezone</FormLabel>
                      <Select onValueChange={field.onChange} value={field.value}>
                        <FormControl>
                          <SelectTrigger data-testid="select-org-timezone">
                            <SelectValue placeholder="Select timezone" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="Asia/Kolkata">India Standard Time (IST)</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <div className="space-y-4 border-t pt-6 mt-6">
                <h3 className="text-sm font-medium">Headquarters Address</h3>
                
                <FormField
                  control={form.control}
                  name="addressLine1"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Street Address</FormLabel>
                      <FormControl>
                        <Input {...field} data-testid="input-org-address" />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <div className="grid grid-cols-2 gap-4">
                  <FormField
                    control={form.control}
                    name="city"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>City</FormLabel>
                        <FormControl>
                          <Input {...field} data-testid="input-org-city" />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name="state"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>State</FormLabel>
                        <FormControl>
                          <Input {...field} data-testid="input-org-state" />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <FormField
                    control={form.control}
                    name="postalCode"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>PIN Code</FormLabel>
                        <FormControl>
                          <Input {...field} data-testid="input-org-pin" />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name="country"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Country</FormLabel>
                        <FormControl>
                          <Input {...field} disabled data-testid="input-org-country" />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>
              </div>

              <div className="space-y-4 border-t pt-6 mt-6">
                <h3 className="text-sm font-medium">Invoice branding</h3>
                <FormField
                  control={form.control}
                  name="logoUrl"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Invoice Logo</FormLabel>
                      <FormControl>
                        <ImageUploader
                          value={field.value || null}
                          onChange={(next) => field.onChange(next ?? "")}
                          testId="org-logo"
                        />
                      </FormControl>
                      <FormDescription>
                        Shown at the top of every invoice, purchase order and delivery challan. PNG/JPEG, up to 2 MB recommended.
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="invoiceFooter"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Invoice footer</FormLabel>
                      <FormControl>
                        <Textarea
                          {...field}
                          rows={3}
                          placeholder="Bank details, terms of payment, thank-you note..."
                          data-testid="input-org-invoice-footer"
                        />
                      </FormControl>
                      <FormDescription>
                        Appears at the bottom of every invoice PDF.
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>

              <div className="flex justify-end pt-4">
                <Button 
                  type="submit" 
                  disabled={updateMutation.isPending}
                  data-testid="btn-save-settings"
                >
                  {updateMutation.isPending ? "Saving..." : "Save Settings"}
                </Button>
              </div>
            </form>
          </Form>
        </CardContent>
      </Card>

      <LogoSettingsCard />

      <BarcodeSettingsCard />

      <PosOrderDiscountCard />

      <SalesChannelWarehouseCard />

      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileCheck2 className="h-5 w-5 text-primary" />
            GST Compliance
          </CardTitle>
          <CardDescription>
            Connect the GST e-invoice (IRP) and e-way bill portals so
            invoices over the mandatory threshold are reported
            automatically.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-2">
          <Link href="/integrations/einvoice">
            <a
              className="flex items-center justify-between rounded-md border p-3 hover-elevate active-elevate-2"
              data-testid="link-settings-einvoice"
            >
              <div>
                <div className="text-sm font-medium">E-invoice (IRP)</div>
                <div className="text-xs text-muted-foreground">
                  Auto-register IRN + signed QR when an order is invoiced.
                </div>
              </div>
              <ChevronRight className="h-4 w-4 text-muted-foreground" />
            </a>
          </Link>
          <Link href="/integrations/ewb">
            <a
              className="flex items-center justify-between rounded-md border p-3 hover-elevate active-elevate-2"
              data-testid="link-settings-ewb"
            >
              <div>
                <div className="text-sm font-medium">E-way bill (NIC)</div>
                <div className="text-xs text-muted-foreground">
                  Generate EWB for shipments above the state threshold.
                </div>
              </div>
              <ChevronRight className="h-4 w-4 text-muted-foreground" />
            </a>
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}

/**
 * POS order-level discount limits. Cashiers cannot apply an order
 * discount that exceeds these org-wide caps. Each limit is
 * independent — set one, both, or neither.
 */
function PosOrderDiscountCard() {
  const { data: org } = useGetCurrentOrganization();
  const queryClient = useQueryClient();
  const { toast } = useToast();

  const [pctStr, setPctStr] = useState("");
  const [amtStr, setAmtStr] = useState("");

  const skipPct = useRef(false);
  const skipAmt = useRef(false);

  useEffect(() => {
    if (org) {
      setPctStr(org.maxOrderDiscountPercent != null ? String(org.maxOrderDiscountPercent) : "");
      setAmtStr(org.maxOrderDiscountAmount != null ? String(org.maxOrderDiscountAmount) : "");
    }
  }, [org]);

  const mutation = useUpdateCurrentOrganization({
    mutation: {
      onSuccess: () => {
        queryClient.invalidateQueries({ queryKey: getGetCurrentOrganizationQueryKey() });
        toast({ title: "POS discount limits saved" });
      },
      onError: () => {
        toast({ title: "Could not save discount limits", variant: "destructive" });
      },
    },
  });

  if (!org) return null;

  const pctVal = pctStr === "" ? null : Math.min(100, Math.max(0, Number(pctStr)));
  const amtVal = amtStr === "" ? null : Math.max(0, Number(amtStr));

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <ShoppingCart className="h-5 w-5 text-primary" />
          POS Order Discount Limits
        </CardTitle>
        <CardDescription>
          Cap the order-level discount cashiers can apply in POS. Set a
          percentage limit, a fixed ₹ amount limit, or both. Leave blank
          for no limit.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="max-order-discount-pct">
              Max Order Discount (%)
            </label>
            <div className="relative">
              <Input
                id="max-order-discount-pct"
                type="number"
                min={0}
                max={100}
                step="0.01"
                value={pctStr}
                placeholder="No limit"
                onChange={(e) => {
                  skipPct.current = true;
                  const raw = e.target.value;
                  if (raw === "") {
                    setPctStr("");
                    return;
                  }
                  const v = Math.min(100, Math.max(0, Number(raw)));
                  setPctStr(String(v));
                }}
                data-testid="input-max-order-discount-pct"
              />
              <span className="pointer-events-none absolute right-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">%</span>
            </div>
            <p className="text-xs text-muted-foreground">
              Cashier cannot give more than this % off the order subtotal.
            </p>
          </div>

          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="max-order-discount-amt">
              Max Order Discount (₹)
            </label>
            <div className="relative">
              <span className="pointer-events-none absolute left-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">₹</span>
              <Input
                id="max-order-discount-amt"
                type="number"
                min={0}
                step="0.01"
                value={amtStr}
                placeholder="No limit"
                className="pl-7"
                onChange={(e) => {
                  skipAmt.current = true;
                  const raw = e.target.value;
                  if (raw === "") {
                    setAmtStr("");
                    return;
                  }
                  setAmtStr(String(Math.max(0, Number(raw))));
                }}
                data-testid="input-max-order-discount-amt"
              />
            </div>
            <p className="text-xs text-muted-foreground">
              Cashier cannot give more than this fixed ₹ amount off the order.
            </p>
          </div>
        </div>

        <div className="flex justify-end">
          <Button
            onClick={() =>
              mutation.mutate({
                data: {
                  maxOrderDiscountPercent: pctVal,
                  maxOrderDiscountAmount: amtVal,
                },
              })
            }
            disabled={mutation.isPending}
            data-testid="btn-save-pos-discount-limits"
          >
            {mutation.isPending ? "Saving…" : "Save discount limits"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

/**
 * Per-org barcode auto-generation settings: prefix + format. Format
 * is currently locked to Code 128, but exposing the select keeps the
 * UI honest about what we plan to add (EAN-13 / UPC-A) and lines up
 * with the persisted column.
 */
function BarcodeSettingsCard() {
  const { data: org } = useGetCurrentOrganization();
  const queryClient = useQueryClient();
  const { toast } = useToast();
  const [prefix, setPrefix] = useState("");

  useEffect(() => {
    if (org) setPrefix(org.barcodePrefix ?? "");
  }, [org]);

  const mutation = useUpdateOrganizationBarcodeSettings({
    mutation: {
      onSuccess: () => {
        queryClient.invalidateQueries({
          queryKey: getGetCurrentOrganizationQueryKey(),
        });
        toast({ title: "Barcode settings saved" });
      },
      onError: (err: unknown) => {
        const e = err as { response?: { data?: { error?: string } } };
        toast({
          title: "Could not save barcode settings",
          description: e.response?.data?.error ?? "Please try again.",
          variant: "destructive",
        });
      },
    },
  });

  if (!org) return null;

  const cleaned = prefix
    .toUpperCase()
    .replace(/[^A-Z0-9]/g, "")
    .slice(0, 8);

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <ScanLine className="h-5 w-5 text-primary" />
          Barcodes
        </CardTitle>
        <CardDescription>
          New items automatically receive a unique Code 128 barcode that
          starts with this prefix. Leave blank to use the default
          derived from your workspace name.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="grid md:grid-cols-2 gap-4">
          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="barcode-prefix">
              Prefix
            </label>
            <Input
              id="barcode-prefix"
              value={prefix}
              maxLength={8}
              placeholder={org.slug.toUpperCase().slice(0, 8) || "INV"}
              onChange={(e) => setPrefix(e.target.value)}
              data-testid="input-barcode-prefix"
            />
            <p className="text-xs text-muted-foreground">
              1-8 letters or digits. Stored as{" "}
              <span className="font-mono">{cleaned || "(default)"}</span>.
            </p>
          </div>
          <div className="space-y-2">
            <label className="text-sm font-medium" htmlFor="barcode-format">
              Format
            </label>
            <Select value="code128" disabled>
              <SelectTrigger
                id="barcode-format"
                data-testid="select-barcode-format"
              >
                <SelectValue />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="code128">Code 128</SelectItem>
              </SelectContent>
            </Select>
            <p className="text-xs text-muted-foreground">
              Code 128 supports the alphanumeric prefix scheme. EAN-13
              and UPC-A will be added later.
            </p>
          </div>
        </div>
        <div className="flex justify-end">
          <Button
            onClick={() =>
              mutation.mutate({
                data: {
                  barcodePrefix: cleaned ? cleaned : null,
                  barcodeFormat: "code128",
                },
              })
            }
            disabled={mutation.isPending}
            data-testid="btn-save-barcode-settings"
          >
            {mutation.isPending ? "Saving…" : "Save barcode settings"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

function LogoSettingsCard() {
  const { data: org } = useGetCurrentOrganization();
  const queryClient = useQueryClient();
  const { toast } = useToast();

  const orgAny = org as (typeof org & {
    loginLogoUrl?: string | null;
    sidebarLogoUrl?: string | null;
    thermalLogoUrl?: string | null;
  }) | undefined;

  const [loginLogoUrl, setLoginLogoUrl] = useState<string | null>(null);
  const [sidebarLogoUrl, setSidebarLogoUrl] = useState<string | null>(null);
  const [thermalLogoUrl, setThermalLogoUrl] = useState<string | null>(null);

  useEffect(() => {
    if (orgAny) {
      setLoginLogoUrl(orgAny.loginLogoUrl ?? null);
      setSidebarLogoUrl(orgAny.sidebarLogoUrl ?? null);
      setThermalLogoUrl(orgAny.thermalLogoUrl ?? null);
    }
  }, [org]);

  const mutation = useUpdateCurrentOrganization({
    mutation: {
      onSuccess: () => {
        queryClient.invalidateQueries({ queryKey: getGetCurrentOrganizationQueryKey() });
        toast({ title: "Logo settings saved" });
      },
      onError: () => {
        toast({ title: "Could not save logo settings", variant: "destructive" });
      },
    },
  });

  if (!org) return null;

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <ImageIcon className="h-5 w-5 text-primary" />
          Logo Settings
        </CardTitle>
        <CardDescription>
          Upload separate logos for the login page, sidebar, and thermal barcode labels. Each logo is only used in its respective location. Leave blank to fall back to the Invoice Logo.
        </CardDescription>
      </CardHeader>
      <CardContent className="space-y-6">
        <div className="space-y-2">
          <label className="text-sm font-medium">Login Page Logo</label>
          <ImageUploader
            value={loginLogoUrl}
            onChange={(next) => setLoginLogoUrl(next ?? null)}
            testId="login-logo"
          />
          <p className="text-xs text-muted-foreground">
            Shown on the sign-in and sign-up screens. PNG/JPEG, up to 2 MB recommended.
          </p>
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium">Sidebar Logo</label>
          <ImageUploader
            value={sidebarLogoUrl}
            onChange={(next) => setSidebarLogoUrl(next ?? null)}
            testId="sidebar-logo"
          />
          <p className="text-xs text-muted-foreground">
            Shown in the top-left of the app sidebar. PNG/JPEG, up to 2 MB recommended.
          </p>
        </div>

        <div className="space-y-2">
          <label className="text-sm font-medium">Thermal Print Logo (B&W)</label>
          <ImageUploader
            value={thermalLogoUrl}
            onChange={(next) => setThermalLogoUrl(next ?? null)}
            testId="thermal-logo"
          />
          <p className="text-xs text-muted-foreground">
            Printed on 50 mm × 25 mm thermal barcode labels. Use a high-contrast black-and-white image for best results.
          </p>
        </div>

        <div className="flex justify-end">
          <Button
            onClick={() =>
              mutation.mutate({
                data: {
                  loginLogoUrl: loginLogoUrl || null,
                  sidebarLogoUrl: sidebarLogoUrl || null,
                  thermalLogoUrl: thermalLogoUrl || null,
                } as Parameters<typeof mutation.mutate>[0]["data"],
              })
            }
            disabled={mutation.isPending}
            data-testid="btn-save-logo-settings"
          >
            {mutation.isPending ? "Saving…" : "Save logo settings"}
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}

const CHANNEL_LABELS: Record<string, string> = {
  pos: "POS",
  walkin: "Walk-in",
  website: "Website",
  store: "Store",
  whatsapp: "WhatsApp",
  phone: "Phone",
  instagram: "Instagram",
  other: "Other",
};

const ALL_CHANNELS = ["pos", "walkin", "website", "store", "whatsapp", "phone", "instagram", "other"];

function SalesChannelWarehouseCard() {
  const { toast } = useToast();
  const { data: defaults, refetch } = useListSalesChannelDefaults();
  const { data: warehousesData } = useListWarehouses();
  const warehouses = (warehousesData ?? []).filter((w) => !w.isVirtual);

  const addDefault = useSetSalesChannelDefault({
    mutation: {
      onSuccess: () => refetch(),
      onError: () => {
        toast({ title: "Could not add warehouse to channel", variant: "destructive" });
      },
    },
  });

  const removeWarehouse = async (channel: string, warehouseId: number) => {
    try {
      const res = await fetch(`/api/sales-channel-defaults/${channel}/${warehouseId}`, {
        method: "DELETE",
      });
      if (!res.ok) throw new Error("failed");
      refetch();
    } catch {
      toast({ title: "Could not remove warehouse from channel", variant: "destructive" });
    }
  };

  // Build a map: channel → array of { warehouseId, warehouseName }
  const currentMap: Record<string, Array<{ warehouseId: number; warehouseName: string }>> = {};
  for (const d of defaults ?? []) {
    if (!currentMap[d.salesChannel]) currentMap[d.salesChannel] = [];
    if (d.warehouseId != null) {
      currentMap[d.salesChannel].push({
        warehouseId: d.warehouseId,
        warehouseName: d.warehouseName ?? String(d.warehouseId),
      });
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <Store className="h-5 w-5 text-primary" />
          Sales Channel Warehouses
        </CardTitle>
        <CardDescription>
          Assign one or more warehouses to each sales channel. POS will show
          combined stock from all assigned warehouses and automatically use the
          first one at checkout. Leave a channel unset to fall back to the
          organisation default.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <div className="space-y-4">
          {ALL_CHANNELS.map((ch) => {
            const assigned = currentMap[ch] ?? [];
            const assignedIds = new Set(assigned.map((a) => a.warehouseId));
            const available = warehouses.filter((w) => !assignedIds.has(w.id));

            return (
              <div
                key={ch}
                className="flex items-start gap-4"
                data-testid={`row-channel-${ch}`}
              >
                <span className="text-sm font-medium w-28 shrink-0 pt-1">
                  {CHANNEL_LABELS[ch] ?? ch}
                </span>
                <div className="flex-1 flex flex-wrap items-center gap-2 min-h-[34px]">
                  {assigned.map((a) => (
                    <span
                      key={a.warehouseId}
                      className="inline-flex items-center gap-1 bg-primary/10 text-primary text-xs font-medium px-2.5 py-1 rounded-full"
                    >
                      {a.warehouseName}
                      <button
                        type="button"
                        aria-label={`Remove ${a.warehouseName}`}
                        onClick={() => removeWarehouse(ch, a.warehouseId)}
                        className="ml-0.5 rounded-full hover:bg-primary/20 p-0.5 transition-colors"
                      >
                        <X className="h-3 w-3" />
                      </button>
                    </span>
                  ))}
                  {available.length > 0 && (
                    <Select
                      value=""
                      onValueChange={(v) => {
                        if (!v) return;
                        addDefault.mutate({
                          channel: ch,
                          data: { warehouseId: Number(v) },
                        });
                      }}
                      disabled={addDefault.isPending}
                    >
                      <SelectTrigger
                        className="h-7 w-auto gap-1 px-2 text-xs border-dashed text-muted-foreground"
                        data-testid={`select-channel-warehouse-${ch}`}
                      >
                        <Plus className="h-3 w-3" />
                        {assigned.length === 0 ? "Add warehouse" : "Add another"}
                      </SelectTrigger>
                      <SelectContent>
                        {available.map((w) => (
                          <SelectItem key={w.id} value={String(w.id)}>
                            {w.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  )}
                  {assigned.length === 0 && available.length === 0 && (
                    <span className="text-xs text-muted-foreground italic">No warehouses available</span>
                  )}
                </div>
              </div>
            );
          })}
        </div>
      </CardContent>
    </Card>
  );
}
