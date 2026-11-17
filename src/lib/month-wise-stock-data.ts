import { supabase } from "@/integrations/supabase/client";
import { getMasterRows, mastersQuery } from "@/lib/sap-master";
import { mapStockRows, valuationLookup, zpcLookup, type StockRow } from "@/lib/month-wise-stock-map";

async function masterRows(cat: "zpc_group" | "valuation_subgroup") {
  const ms = await mastersQuery(cat).queryFn();
  return (await Promise.all(ms.map((m) => getMasterRows(m.id)))).flat();
}

export const monthWiseStockQuery = {
  queryKey: ["month-wise-stock", "v2-no-total-row"] as const,
  queryFn: async (): Promise<StockRow[]> => {
    const raw: { id: string; month: number; year: number; data: Record<string, string> }[] = [];
    let last: string | null = null;
    for (;;) {
      let q = supabase.from("month_wise_upload").select("id,month,year,data").order("id").limit(1000);
      if (last) q = q.gt("id", last);
      const { data, error } = await q;
      if (error) throw error;
      const rows = (data ?? []) as unknown as typeof raw;
      raw.push(...rows);
      if (rows.length < 1000) break;
      last = rows[rows.length - 1]!.id;
    }
    const [zpc, val] = await Promise.all([masterRows("zpc_group"), masterRows("valuation_subgroup")]);
    return mapStockRows(raw, valuationLookup(val), zpcLookup(zpc));
  },
  staleTime: Infinity, refetchOnWindowFocus: false,
};
