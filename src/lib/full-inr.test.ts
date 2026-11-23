import { describe, expect, it } from "vitest";
import { fullInr, inr2 } from "./format";
describe("full rupee values in tables/Excel", () => {
  it("shows full Indian-grouped rupees, not crores", () => expect(fullInr(12345678.9)).toBe("1,23,45,678.90"));
  it("rounds Excel values to 2 decimals", () => expect(inr2(1.23456 * 1e7)).toBe(12345600));
});
