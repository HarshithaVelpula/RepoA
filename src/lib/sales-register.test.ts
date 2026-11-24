import { describe, expect, it } from "vitest";
import { buildSalesRegister, type SalesRegisterRow } from "./sales-register";

const row = (channel: string, netValue: number, invoiceValue: number) => ({ channel, channelCode: "", netValue, invoiceValue, billingDate: "2026-04-01" }) as unknown as SalesRegisterRow;

describe("Sales Register distribution channel", () => {
  it("adds Net Value (without tax) so channels equal the Net Value tile", () => {
    const a = buildSalesRegister([row("Domestic Sales", 100, 118), row("Export Sales", 50, 50)]);
    expect(a.byChannel.reduce((s, d) => s + d.value, 0)).toBe(150);
    expect(a.totalNet).toBe(150);
  });
});
