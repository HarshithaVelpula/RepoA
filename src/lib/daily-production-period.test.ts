import { describe, expect, it } from "vitest";
import { dprPeriodSummary, type DprRow } from "./daily-production-data";
import { currentReportPeriod } from "./report-period";

const row = (date: string, value: number, scrapVal: number, syncedAt = "2026-11-19T05:00:00Z") => ({ date, value, scrapVal, syncedAt } as DprRow);

describe("Daily Production current financial year summary", () => {
  it("counts only rows from 1 April to today", () => {
    const fy = currentReportPeriod(new Date("2026-11-19T10:00:00Z"));
    expect(fy.from).toBe("2026-04-01");
    const s = dprPeriodSummary([row("2026-03-31", 100, 1), row("2026-04-01", 200, 5), row("2026-06-10", 300, 10, "2026-11-19T06:00:00Z")], fy.from, fy.to);
    expect(s).toEqual({ production: 500, scrap: 15, count: 2, syncedAt: "2026-11-19T06:00:00Z" });
  });
});
