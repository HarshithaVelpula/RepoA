# Radiant card backgrounds on Sales screens + radiant model bars

## What changes
1. **Card backgrounds like Purchase Register** — every card on Net Sales (and the other Sales & Distribution dashboards that use the same cards) gets the same soft radiant tinted background and coloured heading underline that Purchase Register cards have. Each card gets its own tint (sky, peach, teal, violet, amber, mint, rose…), same palette as Purchase.
2. **Sales by Model and Model Wise Type** — each bar gets its own radiant colour (top-to-bottom gradient, same style as Purchase bars) on every screen where these cards appear, including the launchpad view if shown.
3. **PDFs** — the tinted card backgrounds and radiant bars are kept in the PDF exactly as on screen (Net Sales, Sales Register and other SD PDFs). Tables stay out of PDFs; header/logo/footer unchanged.

## Technical details
- Reuse `TINTS` from src/lib/card-tints.ts; add a title→tint map in sd-live-dashboard.tsx and model-type-cards.tsx, replacing `bg-card` section styling with the tint style + bordered heading (same as purchase-register `Card`).
- model-type-cards.tsx: add per-bar `<linearGradient>` defs and `<Cell fill="url(#id-i)">` for each bar, verifying the previous change actually reaches the rendered chart (unique gradient ids per card so they don't clash).
- PDF capture already preserves screen colours; confirm gradient defs render in the captured image.
- Verify with Playwright: screenshot Net Sales cards and download PDF.
