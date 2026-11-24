import { expect, test } from "vitest";
import { zpcLookup, mapStockRows } from "@/lib/month-wise-stock-map";
const z = zpcLookup([{ BLUPA: "1000", PRCTR: "COFF100001", MNGRP1: "OTHERS", PCGRP1: "CORPORATE & CS", PCGRP2: "CORP", PCGRP3: "CORP" }]);
test("Profit Center spelling maps groups", () => {
  const [r] = mapStockRows([{ id: "1", month: 11, year: 2026, data: { ValCl: "4011", Plnt: "1000", "Profit Center": "COFF100001" } }], new Map(), z);
  expect(r!.sub3).toBe("CORP");
});
test("plant code BLUPA maps groups when profit centre missing", () => {
  const [r] = mapStockRows([{ id: "1", month: 11, year: 2026, data: { ValCl: "4011", Plnt: "1000" } }], new Map(), z);
  expect(r!.mainGroup).toBe("OTHERS");
});
