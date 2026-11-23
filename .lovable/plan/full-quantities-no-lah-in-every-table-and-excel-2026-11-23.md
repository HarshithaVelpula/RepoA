# Full quantities (no LAH) in every table and Excel

Same rule as the values change: detailed tables, their total rows and Excel downloads show the full number. Tiles, cards and charts keep LAH / ₹ Cr.

## What changes
- **Sales Register** table and Excel: Billed Qty, CGST, SGST and IGST show full figures (quantity in units, taxes in full ₹). Headings become "Billed Qty", "CGST (₹)", "SGST (₹)", "IGST (₹)".
- **Order Book** table and Excel: Open Qty, Delivered Qty and Total AH show full figures; headings drop "(LAH)".
- **Sales In Transit** table and Excel: AH and Total AH show full figures; headings drop "(LAH)".
- Open Sales Orders, Purchase, Inventory and Production tables already show full quantities — no change.

## Technical details
- Replace `toLah(...)` / LAH formatting in sales-register-dashboard.tsx, sales-register-export.ts, open-sales-orders-dashboard.tsx (row cells and footer) and open-sales-orders-export.ts with full en-IN numbers (2 dp for ₹, up to 3 dp for quantities); Excel cells stay numeric.
- Extend the existing full-value test with one quantity case.
