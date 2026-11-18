/**
 * Maps the SAP ZDPR (Daily Production Report) response into `public.daily_production` rows.
 * Typed column per SAP field plus the raw row; upserted on MBLNR + MJAHR + ZEILE.
 */
import { orderBookNum } from "./order-book-map";

const TEXT: Record<string, string> = {
  WERKS: "werks", ZSTAGE: "zstage", BWART: "bwart", MATNR: "matnr", LGORT: "lgort", CHARG: "charg", MEINS: "meins", AUFNR: "aufnr",
  MAKTX: "maktx", KDAUF: "kdauf", KDPOS: "kdpos", WAERS: "waers", ARBPL: "arbpl", KTEXT_UP: "ktext_up", STLBEZ: "stlbez", NAME1: "name1",
  MODEL: "model", RANGE: "range_txt", TYPE: "type_txt", COMB: "comb", CONT_REF: "cont_ref", CELL_TYPE: "cell_type", STAGE: "stage",
  ZKOSTL: "zkostl", ZKOSTL_NAME: "zkostl_name", USNAM: "usnam", UNAME: "uname",
};
const NUM: Record<string, string> = {
  MENGE: "menge", DMBTR: "dmbtr", RATE: "rate", BEAMS: "beams", AVG_COUNT: "avg_count", TMTRS: "tmtrs", AGE: "age", AH: "ah", TOTAH: "totah",
  POS_PLATES: "pos_plates", NEG_PLATES: "neg_plates", WIDTH: "width", STACK_CELL: "stack_cell", SCRAP_QTY: "scrap_qty", SCRAP_VALUE: "scrap_value",
};
const DATES: Record<string, string> = { BUDAT_MKPF: "budat", GLTRP: "gltrp", GSTRP: "gstrp" };

export function isDailyProductionEndpoint(name: string): boolean {
  const n = (name ?? "").replace(/[^a-z0-9]/gi, "").toLowerCase();
  return n.includes("dailyproduction") || n === "zdpr";
}

const norm = (k: string) => k.replace(/[^a-z0-9]/gi, "").toLowerCase();
function pick(raw: Record<string, unknown>, key: string): unknown {
  if (raw[key] !== undefined) return raw[key];
  const real = Object.keys(raw).find((k) => norm(k) === norm(key)); // tolerates "SCRAP_V ALUE"
  return real ? raw[real] : undefined;
}
function text(v: unknown): string | null {
  if (v === undefined || v === null || typeof v === "object") return null;
  const s = String(v).trim();
  return s ? s : null;
}
export function sapIsoDate(v: unknown): string | null {
  const s = text(v);
  if (!s || /^0+$/.test(s.replace(/\D/g, ""))) return null;
  let m = s.match(/^(\d{4})-?(\d{2})-?(\d{2})/);
  if (m) return `${m[1]}-${m[2]}-${m[3]}`;
  m = s.match(/^(\d{1,2})[./-](\d{1,2})[./-](\d{4})$/);
  return m ? `${m[3]}-${m[2]!.padStart(2, "0")}-${m[1]!.padStart(2, "0")}` : null;
}
function extractRows(payload: unknown): Record<string, unknown>[] {
  if (Array.isArray(payload)) return payload.filter((r) => r && typeof r === "object") as Record<string, unknown>[];
  if (payload && typeof payload === "object") {
    const obj = payload as Record<string, unknown>;
    for (const key of ["data", "DATA", "results", "items", "value"]) if (Array.isArray(obj[key])) return extractRows(obj[key]);
  }
  return [];
}

export function mapDailyProductionPayload(payload: unknown, endpointName: string, now = new Date()) {
  const source = extractRows(payload);
  const syncedAt = now.toISOString();
  const byKey = new Map<string, Record<string, unknown>>();
  let invalid = 0;
  for (const raw of source) {
    const mblnr = text(pick(raw, "MBLNR"));
    if (!mblnr) { invalid++; continue; }
    const mjahr = text(pick(raw, "MJAHR")) ?? "", zeile = text(pick(raw, "ZEILE")) ?? "";
    const row: Record<string, unknown> = { mblnr, mjahr, zeile, raw, source_endpoint: endpointName, synced_at: syncedAt };
    for (const [k, c] of Object.entries(TEXT)) row[c] = text(pick(raw, k));
    for (const [k, c] of Object.entries(NUM)) row[c] = orderBookNum(pick(raw, k));
    for (const [k, c] of Object.entries(DATES)) row[c] = sapIsoDate(pick(raw, k));
    byKey.set(`${mblnr}|${mjahr}|${zeile}`, row);
  }
  const rows = [...byKey.values()];
  return { received: source.length, rows, invalid, duplicates: source.length - invalid - rows.length };
}
