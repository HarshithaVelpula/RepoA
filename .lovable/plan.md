# Full ₹ values in every table and Excel (no Cr)

Tiles, cards and charts stay in ₹ Cr. Only the detailed tables on screen, their totals rows, and the Excel downloads switch to full rupee values (Indian format, 2 decimals, e.g. 1,23,45,678.90). Column headings drop "(₹ Cr)" / "(Cr)" and become "(₹)".

## Screens covered
- **Open Sales Orders, Order Book, Sales In Transit** — Open / Order / SIT Value column and Excel.
- **Sales Register** — Net Value column, Excel details sheet, and the Industry / Segment Excel sheets.
- **Open Purchase Orders** — PO Value, MIGO Value, Open Value columns and Excel.
- **Purchase Orders List** — Net Order Val column and Excel.
- **ZKEYRM Comparison tables** (Purchase Register, Purchase Orders List, Month Wise Stock) — PO Val / Value columns and Excel.
- **Material price detail screen** — Value column and Excel.
- **Cash Flow History** table — Credit / Debit / Net.
- Already in full value (checked, no change): Purchase Register, Current Stock, Daily Production Report, Month Wise Stock details.

Quantities shown in LAH (Billed Qty, AH, CGST/SGST/IGST in LAH) are not touched — only crore values.

## Technical details
- Add a shared `fullInr(n)` formatter (en-IN, 2 dp) in src/lib, use it in table cells, footers and Excel rows; multiply back where rows store Cr (open-sales-orders value ×1e7, open-po/purchase-orders Cr fields) instead of re-reading data.
- Files: open-sales-orders-dashboard.tsx + open-sales-orders-export.ts, sales-register-dashboard.tsx + sales-register-export.ts, open-po-dashboard.tsx, purchase-orders-dashboard.tsx, zrmmat-compare-card.tsx, material-price-page.tsx, cash-flow-dashboard.tsx.
- Excel numeric cells keep numFmt `#,##,##0.00`.
- Small test: fullInr(12345678.9) → "1,23,45,678.90".
