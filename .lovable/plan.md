# PDF fixes: Sales Register header, no filters, same colours everywhere

## 1. Sales Register PDF (same as Net Sales)
- Hide the Filters card in the PDF.
- Add the same top header shown in Net Sales PDF: HBL logo + "HBL Engineering Limited" on the left, "Sales Register" title on the right.
- Add the "HBL Confidential — Internal Use Only" footer with page numbers, and keep charts/cards from splitting across pages.
- Header appears only in the PDF, not on screen.

## 2. Same background colours as Purchase module in every PDF
Purchase screens keep the on-screen card/chart colours in the PDF. Turn the same option on for the screens that don't have it yet:
- Net Sales
- Sales Register
- TBN

Open Sales Orders, Order Book, SIT, Purchase, Inventory, Production and Cash Flow already use it — no change.

## Technical details
- `src/routes/_authenticated/reports/sd/dispatches.tsx`: wrap filters in `data-pdf-exclude`; render `data-pdf-header` (logo) while busy; call `exportDashboardPdf(..., "[data-pdf-exclude]", { headerSelector, footerText, preserveComputedChartColors: true })`, matching purchase-register.tsx.
- `src/components/sd-live-dashboard.tsx` and `src/components/tbn-dashboard.tsx`: add `preserveComputedChartColors: true` (TBN also gets exclude/header/footer options).
- Screen layout unchanged; only PDF output differs.
