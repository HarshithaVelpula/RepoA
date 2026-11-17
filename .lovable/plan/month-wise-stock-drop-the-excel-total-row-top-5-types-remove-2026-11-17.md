# Month Wise Stock: drop the Excel total row, Top 5 types, remove "Val" from tiles

## Changes
1. **Excel total row ignored**: "Unassigned" is the sum row in the uploaded sheet. That row has no valuation class, plant or material. It will be skipped everywhere: tiles, Total Inv, the month chart, every card, filters, the table, Excel, PDF and the launchpad. This stops the total being counted twice (today 1,617.58 = 2 × 808.79), so Total Inv becomes about 808.79 Cr.
2. **Top Types shows the Top 5**: the remaining types go under the "Others (N)" button, which lists them.
3. **Tile labels**: " Val" is removed from every tile, e.g. "Total Inv", "Raw material", "SFG", "FG". Values stay in ₹ Cr.

## Technical
- src/lib/month-wise-stock-map.ts: drop rows with an empty ValCl (and no material) in the mapper, so every screen and the launchpad inherit the fix. Add a test.
- month-wise-stock-dashboard.tsx: `topWithOthers(types, 5)`; tile labels `t.name` and "Total Inv".
- Bump the month-wise-stock query key.
