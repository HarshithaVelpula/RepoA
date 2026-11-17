# Month Wise Stock: ZKEYRM Comparison back to ₹ prices (like Purchase Register)

## What changes
- Undo the last change on the Month Wise Stock ZKEYRM Comparison card: prices go back to plain ₹ with 2 decimals, same as the Purchase Register card.
  - Unit Price tile: e.g. 0.0001 becomes about 1,371.40 (₹ per KG).
  - Unit Price Variance tile, chart bars/labels/axis, Avg Price, vs prev month and Diff from first columns: all in ₹, so the numbers are readable instead of 0.0001 / -0.0000.
- Values that are already in ₹ Cr stay in ₹ Cr: Total Procurement Value tile and the PO Val (₹ Cr) column — exactly like the Purchase Register screen.
- Excel download from this card uses the same ₹ headings.
- Purchase Register and Purchase Orders List stay unchanged.

## Technical details
- In `src/components/month-wise-stock-dashboard.tsx`, remove the `priceInCr` prop from `<ZrmmatCompareCard />`. The card's default (₹, 2 decimals) is already what Purchase Register uses; the optional prop stays in the card but goes unused.
