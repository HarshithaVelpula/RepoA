# Sales Register: matching channel totals, Invoice Value column, readable PDF

## 1. Why Distribution Channel (₹ 2,340 Cr) and Net Value (₹ 2,279 Cr) differ
- The **Net Value tile** adds NETWR_EX (value **without** tax).
- The **Distribution Channel card**, and the other ranked cards (Customers, Profit Centres, Materials, Plant), add NETWR_T (value **with** tax), which comes to about ₹ 61 Cr more.
- Both are correct sums of two different SAP fields. It was already like this; today's change only made the ₹ values visible. Production shows the same, because it uses the same code and the same stored rows.

**Fix:** every card adds Net Value (NETWR_EX), so all the channels together equal ₹ 2,279 Cr. The launchpad already uses NETWR_EX.

## 2. Table and Excel
- Add an **Invoice Value (₹)** column (NETWR_T, with tax, full ₹) next to Net Value (₹), in both the table and the Excel file. The totals row includes it.

## 3. PDF is too small, headings are cut, and the sides are empty
- **Cause:** the Sales Register screen is captured as one tall picture. The PDF shrinks that picture to fit a single page height, which leaves big empty margins on the left and right and makes headings and text tiny or cut off.
- **Fix:** capture each row of cards separately, at full page width, and move to a new page when a row doesn't fit. Every card then keeps its full width, so headings stay on one line and text stays readable.
- Check every other screen's PDF (Net Sales, Open Orders/Order Book/SIT, TBN, Purchase Register, Purchase Orders List, Open PO, Current Stock, Month Wise Stock, Daily Production) and apply the same row split where a screen is captured as one block.

## Technical details
- `sales-register.ts`: `rollup` sums `netValue`; the donut centre uses `totalNet`. Add a test that the channel sum equals `totalNet`.
- `sales-register-dashboard.tsx` and `sales-register-export.ts`: add an Invoice Value column from `invoiceValue`.
- Mark each dashboard row with `data-pdf-block` and pass `blockSelector: "[data-pdf-block]"` to `exportDashboardPdf` for every screen whose root holds only one child.
- Verify by generating the Sales Register PDF with Playwright and viewing the pages.
