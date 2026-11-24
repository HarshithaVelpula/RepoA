import { describe, it, expect } from "vitest";
import { mapCurrentStockPayload } from "./current-stock-map";
describe("current stock mapper", () => {
  it("reads new SAP keys and trims material zeros", () => {
    const { rows } = mapCurrentStockPayload([{ WERKS: "1000", MATNR: "000000009500000552", UNRESTRICTED_VALUE: 298305, QC_VALUE: 10, BLOCKED_VALUE: 5 }], "x");
    expect(rows[0]?.["matnr"]).toBe("9500000552");
    expect(rows[0]?.["wlabs"]).toBe(298305);
    expect(rows[0]?.["winsm"]).toBe(10);
    expect(rows[0]?.["wspem"]).toBe(5);
  });
  it("falls back to WBWBEST when breakdown is zero", () => {
    const { rows } = mapCurrentStockPayload([{ WERKS: "1000", MATNR: "9000029318", MBWBEST: 36, WBWBEST: 85091.4, UNRESTRICTED_QTY: 0, UNRESTRICTED_VALUE: 0, QC_VALUE: 0, BLOCKED_VALUE: 0 }], "x");
    expect(rows[0]?.["wlabs"]).toBe(85091.4);
    expect(rows[0]?.["labst"]).toBe(36);
  });
});
