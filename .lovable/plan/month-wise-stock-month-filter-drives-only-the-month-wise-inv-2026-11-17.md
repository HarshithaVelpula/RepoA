# Month Wise Stock: month filter drives only the Month Wise Inventory card

## What changes
- **Month Wise Inventory card**: shows one bar for every month picked in the Month dropdown (as today).
- **All other tiles and cards** (Total Inv, type tiles, Top 10 Types, Top 15 Plants, Top 10 Materials, Main Group, Sub Group 1/2/3, detailed table): show only the **latest month** among the selected months. Example: pick Aug, Sep, Oct, so the chart shows 3 bars and everything else shows Oct only.
- Their subtitle reads that month (e.g. "Oct-2026") so it is clear which month is shown.
- **ZKEYRM Comparison**: keeps all selected months, because it compares month on month.
- Plant and Type filters still apply to everything.
- **Launchpad Month Wise Stock card**: shows the latest uploaded month only, matching the screen.
- No months selected: the cards show empty.

## Technical details
- In month-wise-stock-dashboard.tsx, keep `filtered` (selected months) for `monthly` and `zk`. Add `latestPeriod = max(months ∩ periods)` and `latest = filtered.filter(r => r.period === latestPeriod)`. Feed `cur`, tiles, group cards, the plants/materials cards and DetailsTable from `latest`.
- Add a pure helper `latestPeriod(periods)` in month-wise-stock-map.ts, with a test.
- Change the launchpad tile in launchpad.tsx to sum only the latest period.
