import { supabase } from "@/integrations/supabase/client";

export const MONTHS = ["January","February","March","April","May","June","July","August","September","October","November","December"];
/** April–March order for the dropdown. */
export const FY_MONTH_ORDER = [4,5,6,7,8,9,10,11,12,1,2,3];
export const BASE_COLUMNS = ["Plnt","Location","Material","Material Description","Profit Centre","SAC/HSN Code","MTyp","ValCl","Val. Type","BUn","OB Qty","OB Val","RCPT Qty","RCPT Val","ISS Qty","ISS Val","CB Qty","CB Val","G/L Acct","Gl Description","Price","Std price","Pr.","Matl Group"];
export const EXTRA_COLUMNS = ["Month","Year","Created Date","Updated Date"];

export type MwuRow = { id: string; month: number; year: number; data: Record<string, string>; created_at: string; updated_at: string };

/** Pure: known columns first in file order, then any other uploaded columns. */
export function orderColumns(rows: { data: Record<string, string> }[]): string[] {
  const seen = new Set<string>();
  rows.forEach((r) => Object.keys(r.data).forEach((k) => seen.add(k)));
  const base = BASE_COLUMNS.filter((c) => seen.has(c));
  return [...base, ...[...seen].filter((c) => !BASE_COLUMNS.includes(c))];
}

/** Pure: drop rows where every cell is empty. */
export const nonEmptyRows = (rows: Record<string, string>[]) => rows.filter((r) => Object.values(r).some((v) => (v ?? "").toString().trim() !== ""));

/** Keyset read of every row for a month (used for Excel export). */
export async function fetchMonthRows(month: number, year: number): Promise<MwuRow[]> {
  const out: MwuRow[] = [];
  let last: string | null = null;
  for (;;) {
    let q = supabase.from("month_wise_upload").select("id,month,year,data,created_at,updated_at").eq("year", year).eq("month", month).order("id").limit(1000);
    if (last) q = q.gt("id", last);
    const { data, error } = await q;
    if (error) throw error;
    const rows = (data ?? []) as unknown as MwuRow[];
    out.push(...rows);
    if (rows.length < 1000) break;
    last = rows[rows.length - 1]!.id;
  }
  return out;
}

export type MwuPage = { total: number; all_total: number; created: string | null; updated: string | null; columns: string[]; rows: MwuRow[] };
/** One server-side page (search + count + timestamps) so large months load instantly. */
export async function fetchMonthPage(month: number, year: number, search: string, offset: number, limit: number): Promise<MwuPage> {
  const { data, error } = await supabase.rpc("month_wise_upload_page", { _month: month, _year: year, _search: search, _offset: offset, _limit: limit });
  if (error) throw error;
  return data as unknown as MwuPage;
}

/** Run async jobs with a fixed number of parallel workers. */
async function pool<T>(items: T[], workers: number, fn: (item: T) => Promise<void>) {
  let i = 0;
  await Promise.all(Array.from({ length: Math.min(workers, items.length) }, async () => { while (i < items.length) await fn(items[i++]!); }));
}

/** Replace a month's rows, keeping its original created date. */
export async function replaceMonth(month: number, year: number, rows: Record<string, string>[], existingCreated: string | null, onProgress?: (d: number, t: number) => void) {
  const { data: u } = await supabase.auth.getUser();
  await deleteMonth(month, year);
  const now = new Date().toISOString();
  const created = existingCreated ?? now;
  const chunks: Record<string, string>[][] = [];
  for (let i = 0; i < rows.length; i += 1000) chunks.push(rows.slice(i, i + 1000));
  let done = 0;
  await pool(chunks, 4, async (c) => {
    const { error } = await supabase.from("month_wise_upload").insert(c.map((d) => ({ month, year, data: d, created_at: created, updated_at: now, created_by: u.user?.id ?? null })));
    if (error) throw error;
    done += c.length;
    onProgress?.(done, rows.length);
  });
}

export async function updateRow(id: string, data: Record<string, string>) {
  const { error } = await supabase.from("month_wise_upload").update({ data, updated_at: new Date().toISOString() }).eq("id", id);
  if (error) throw error;
}
export async function deleteRows(ids: string[], month: number, year: number) {
  for (let i = 0; i < ids.length; i += 50) {
    const { error } = await supabase.from("month_wise_upload").delete().in("id", ids.slice(i, i + 50));
    if (error) throw error;
  }
  await supabase.from("month_wise_upload").update({ updated_at: new Date().toISOString() }).eq("month", month).eq("year", year);
}
/** Delete a whole month in one fast server call. */
export async function deleteMonth(month: number, year: number) {
  const { error } = await supabase.rpc("delete_month_wise_upload", { _month: month, _year: year });
  if (error) throw error;
}
