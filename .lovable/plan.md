# Daily Production Report: launchpad card, data range and current financial year

## 1. Launchpad card
The Daily Production Report card on the launchpad will show figures for the current financial year (01-04-2026 to today):
- Production value (₹ Cr)
- Scrap value (₹ Cr)
- Total count: the number of production entries
- A small "01-04-2026 – today" line, so it's clear which period the figures cover

It uses the same radiant Production Planning colour and "Open" button as the other cards. The figures only change when someone clicks Refresh or Sync on the screen, never on their own.

## 2. "Data available" beside Refresh
At the top of the screen, "Data available: first date – last date" will move next to the Refresh, Sync and PDF buttons, the same way the other screens show it. It is left out of the PDF.

## 3. Open on the current financial year
When the screen opens, Posting Date From is set to 01-04 of the current financial year and To is set to today (India time). Every tile, card, table and Excel follows that range. Changing the dates still works, and Reset goes back to the current financial year.

## Technical details
- Reuse `currentReportPeriod()` from `src/lib/report-period.ts` for the April–March range on both the screen and the launchpad.
- `daily-production-dashboard.tsx`: initialise `from`/`to` from the period, make Reset restore it, and move the "Data available" label into the screen header next to the actions (`data-pdf-exclude`).
- `launchpad.tsx`: add `DailyProductionTile`, rendered for screen key `pp.daily-production-report`. It uses `dailyProductionQuery` (the same stable query the screen uses) with `inReportPeriod` filtering plus `dprTotals`, and the `TableStatusTile` layout with accent 4.
- Add a small test that the current financial year range is applied to the totals.
