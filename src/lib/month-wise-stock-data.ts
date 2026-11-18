import { supabase } from "@/integrations/supabase/client";
import { normMat, zrmmatMaterials } from "@/lib/purchase-zrmmat-compare";
import { getMasterRows, mastersQuery } from "@/lib/sap-master";
import { mapStockRows, valuationLookup, zpcLookup, type StockRow } from "@/lib/month-wise-stock-map";

type Raw = { id: string; month: number; year: number; data: Record<string, string> };

async function masterRows(cat: "zpc_group" | "valuation_subgroup") {
  const ms = await mastersQuery(cat).queryFn();
  return (await Promise.all(ms.map((m) => getMasterRows(m.id)))).flat();
}
async function lookups() {
  const [zpc, val] = await Promise.all([masterRows("zpc_group"), masterRows("valuation_subgroup")]);
  return [valuationLookup(val), zpcLookup(zpc)] as const;
}

/** Database-summed rows (month × ValCl × Profit Centre × Plant, no material): small and fast for tiles/cards. */
export const monthWiseStockQuery = {
  queryKey: ["month-wise-stock", "v6-summary"] as const,
  queryFn: async (): Promise<StockRow[]> => {
    const [res, lk] = await Promise.all([supabase.rpc("month_wise_stock_summary" as never), lookups()]);
    if (res.error) throw res.error;
    return mapStockRows((res.data ?? []) as unknown as Raw[], lk[0], lk[1]);
  },
  staleTime: Infinity, refetchOnWindowFocus: false,
};

/** Full uploaded rows of one month, only for the detailed table / Excel. */
export const monthWiseStockMonthQuery = (period: string) => ({
  queryKey: ["month-wise-stock", "rows-v6", period] as const,
  queryFn: async (): Promise<StockRow[]> => {
    const year = Number(period.slice(0, 4)), month = Number(period.slice(5, 7));
    const raw: Raw[] = []; let last: string | null = null;
    for (;;) {
      let q = supabase.from("month_wise_upload").select("id,month,year,data").eq("year", year).eq("month", month).order("id").limit(1000);
      if (last) q = q.gt("id", last);
      const { data, error } = await q;
      if (error) throw error;
      const rows = (data ?? []) as unknown as Raw[];
      raw.push(...rows);
      if (rows.length < 1000) break;
      last = rows[rows.length - 1]!.id;
    }
    const lk = await lookups();
    return mapStockRows(raw, lk[0], lk[1]);
  },
  staleTime: Infinity, refetchOnWindowFocus: false, enabled: !!period,
});

/** Material-level totals: top 40 materials per month plus every ZKEYRM material (Top Materials + ZKEYRM cards). */
export const monthWiseStockMaterialsQuery = {
  queryKey: ["month-wise-stock", "v6-materials"] as const,
  queryFn: async (): Promise<StockRow[]> => {
    const ms = await mastersQuery("zrmmat").queryFn();
    const zr = (await Promise.all(ms.map((m) => getMasterRows(m.id)))).flat();
    const mats = zrmmatMaterials(zr).map((m) => normMat(m.material));
    const [res, lk] = await Promise.all([supabase.rpc("month_wise_stock_materials" as never, { _mats: mats } as never), lookups()]);
    if (res.error) throw res.error;
    return mapStockRows((res.data ?? []) as unknown as Raw[], lk[0], lk[1]);
  },
  staleTime: Infinity, refetchOnWindowFocus: false,
};

export type StockKpi = { period: string; type: string; value: number };
/** Launchpad: month × valuation class totals only (a few dozen rows). */
export const monthWiseStockKpisQuery = {
  queryKey: ["month-wise-stock", "v5-kpis"] as const,
  queryFn: async (): Promise<StockKpi[]> => {
    const [res, val] = await Promise.all([supabase.rpc("month_wise_stock_kpis" as never), masterRows("valuation_subgroup")]);
    if (res.error) throw res.error;
    const lk = valuationLookup(val);
    return ((res.data ?? []) as { month: number; year: number; vc: string; v: number }[]).map((r) => ({
      period: `${r.year}-${String(r.month).padStart(2, "0")}`, type: lk.get(r.vc.replace(/^0+(?=.)/, "").toUpperCase()) || r.vc, value: Number(r.v) || 0,
    }));
  },
  staleTime: Infinity, refetchOnWindowFocus: false,
};
