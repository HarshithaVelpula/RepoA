# Daily Production Report: launchpad card, data range and current financial year

## 1. Launchpad card
The Daily Production Report card on the launchpad will show figures for the current financial year (01-04-2026 to today):
- Production value (₹ Cr)
- Scrap value (₹ Cr)
- Total count: the number of production entries
- Last Sync time (India time) at the bottom, like the Cash Flow and Net Sales cards

It uses the same radiant Production Planning colour and "Open" button as the other cards. The figures only change when someone clicks Refresh or Sync on the screen, never on their own.

## 2. "Data available" beside Refresh
At the top of the screen, "Data available: first date – last date" will move next to the Refresh, Sync and PDF buttons, the same way the other screens show it. It is left out of the PDF.

## 3. Last Sync on the screen
A "Last Sync: DD.MM.YYYY, hh:mm am/pm IST" label is added beside Refresh, as on Net Sales and Open Orders. It shows when Daily Production data was last saved and is left out of the PDF.

## 4. Open on the current financial year
When the screen opens, Posting Date From is set to 01-04 of the current financial year and To is set to today (India time). Every tile, card, table and Excel follows that range. Changing the dates still works, and Reset goes back to the current financial year.

## Technical details
- Reuse `currentReportPeriod()` from `src/lib/report-period.ts` for the April–March range on both the screen and the launchpad.
- `daily-production-dashboard.tsx`: initialise `from`/`to` from the period, make Reset restore it, and move the "Data available" label into the screen header next to the actions (`data-pdf-exclude`).
- `launchpad.tsx`: add `DailyProductionTile`, rendered for screen key `pp.daily-production-report`. It uses `dailyProductionQuery` (the same stable query the screen uses) with `inReportPeriod` filtering plus `dprTotals`, and the `TableStatusTile` layout with accent 4.
- Last sync is the newest `synced_at` in the loaded rows. It is shown with `lastSyncedLabel` on the screen and `lastSyncShortLabel` on the card.
- Add a small test that the current financial year range is applied to the totals.
