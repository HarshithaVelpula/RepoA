# Month Wise Stock: new layout with Last 3 Months Comparison

## What changes
- **Row 1:** the Month Wise Inventory chart spans the full width on its own.
- **Row 2:** two cards side by side:
  - **Last 3 Months Comparison** (new, left, wider): the top 5 types, each with three bars, one for each of the last 3 uploaded months (e.g. Aug, Sep, Oct). The Month dropdown does not change this card. Each month has its own radiant colour and a legend. Values are in ₹ Cr.
  - **Top 10 Types** (right): unchanged, still with the "Others" button.
- Plant and Type filters apply to the new card. If fewer than 3 months are uploaded, it shows the months available.

## Technical details
- Add a pure helper `lastNMonthsByType(rows, periods, n=3, top=5)` in month-wise-stock-map.ts. It returns `{ months, data: [{ name, [period]: value }] }`, with types ranked by latest-month value. Add a test for it.
- In month-wise-stock-dashboard.tsx, the helper takes rows filtered by plant/type only (not by month). Render a recharts grouped BarChart with SVG gradient defs, using a `lg:grid-cols-[2fr_1fr]` grid in row 2.
