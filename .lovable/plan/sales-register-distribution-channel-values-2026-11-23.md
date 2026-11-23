# Sales Register — Distribution Channel values

Current data has three channels: 01 Domestic Sales, 02 Export Sales, 03 Deemed Export Sales.

## Sales Register screen
- Distribution Channel card: each channel row shows its value in ₹ Cr **and** its % share (today only % is shown), e.g. "01 — Domestic Sales  ₹ 333.12 Cr  82.9%".
- Same in the PDF (the card is captured as shown).

## Launchpad — Sales Register tile
- Below the total, list each Distribution Channel (Domestic / Export / Deemed Export) with invoice-line count, ₹ Cr value and a coloured share bar, the same style as the existing tile rows.
- Uses the user's assigned plants/profit centres, as today.

## Technical details
- `sales-register-dashboard.tsx`: Donut gets a `showValueAndPercent` mode used by the Distribution Channel card; labels "code — description" from vtweg_auft + vtext_dc.
- `open-sales-orders-launch-card.tsx`: fetch `vtweg_auft` too; group the breakdown by "code — vtext_dc" instead of order type; bump query key.
