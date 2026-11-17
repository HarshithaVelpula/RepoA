# Month Wise Stock: ZKEYRM Comparison prices in ₹ Cr

Only on the Month Wise Stock screen (Purchase Register and Purchase Orders List stay unchanged), every rupee figure in the ZKEYRM Comparison card shows in ₹ Cr:

- Tile "Unit Price (₹)" becomes "Unit Price (₹ Cr)". Example: 7,30,000.00 becomes 0.07 (4 decimals, so 0.0730, keeps small prices readable).
- Tile "Unit Price Variance (MoM)" shows the change in ₹ Cr. The % stays the same.
- Chart bars, labels, Y-axis and tooltip "Avg Price" show ₹ Cr.
- Table columns "Avg Price", "vs prev month" and "Diff from first" show ₹ Cr, with "(₹ Cr)" in their headings. Same for the material list and the detail popup prices.
- The Excel download from this card uses the same ₹ Cr values and headings.
- Total Procurement Value and PO Val are already in ₹ Cr. Quantity is unchanged.

## Technical
- Add an optional `priceInCr` prop to ZrmmatCompareCard. When set, divide prices and differences by 1e7 and format with 4 decimals. Label suffixes change from "(₹)" to "(₹ Cr)".
- Pass `priceInCr` from month-wise-stock-dashboard.tsx only.
