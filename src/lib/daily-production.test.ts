import { describe, expect, it } from "vitest";
import { mapDailyProductionPayload } from "./daily-production-map";
import { dprTotals, toDprRow } from "./daily-production-data";

const sample = [{ WERKS: "1600", MBLNR: "4904740743", MJAHR: 2026, ZEILE: 1, MENGE: 100, DMBTR: 533994.66, BUDAT_MKPF: "2026-06-10", "SCRAP_V ALUE": 5765.21, SCRAP_QTY: 25 }];

describe("daily production", () => {
  it("keys lines on MBLNR + MJAHR + ZEILE and reads the spaced SCRAP_VALUE key", () => {
    const { rows } = mapDailyProductionPayload([...sample, ...sample], "Daily_Production_Report");
    expect(rows).toHaveLength(1);
    expect(rows[0]!["scrap_value"]).toBe(5765.21);
    expect(rows[0]!["budat"]).toBe("2026-06-10");
  });
  it("scrap % is scrap qty over good + scrap qty", () => {
    const { rows } = mapDailyProductionPayload(sample, "x");
    expect(dprTotals(rows.map(toDprRow)).scrapPct).toBe(20);
  });
});
