# Month Wise Stock: single multi-select Month filter

1. Replace the two filters "Month From" and "Month To" with one **Month** dropdown where you can tick several months. The list shows every month that has uploaded data, plus "Select all".
2. When the screen opens, the current month (Nov-2026) is ticked. If the current month has no uploaded data, the latest uploaded month is ticked instead.
3. Tiles, cards and the table use only the ticked months. Card subtitles show the ticked months (e.g. "Nov-2026", "Oct-2026, Nov-2026", or "All months" when every month or none is ticked).
4. Reset goes back to the current month.

Technical: in month-wise-stock-dashboard.tsx, replace from/to with `months: string[]` and use the existing filter-multi-select component. Seed it once, after the data loads, with the current IST period (YYYY-MM) if it exists, otherwise the latest. The filter is `!months.length || months.includes(r.period)`. Launchpad is unchanged.
