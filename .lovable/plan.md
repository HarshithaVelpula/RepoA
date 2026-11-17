# Month Wise Stock: hide Unassigned, Top 5 types, drop "Val" from tiles

## Changes
1. **Unassigned hidden** – rows whose valuation class has no match in the Valuation master no longer appear as a type tile, in the Top Types card, or in the Type filter. Total Inv stays the full total of all stock, so it matches the uploaded sheet.
2. **Top Types shows Top 5** – the other types go under the "Others (N)" button, which opens the list of the remaining types.
3. **Tile labels** – " Val" removed from every tile: "Total Inv", "Raw material", "SFG", "FG", and so on. The values are still in ₹ Cr.
4. **Launchpad** – the Month Wise Stock card also hides Unassigned, so it matches the screen.

## Technical
- src/components/month-wise-stock-dashboard.tsx: filter `t.name !== "Unassigned"` for tiles, the Top Types list and the type options; `topWithOthers(types, 5)`; labels `t.name` and "Total Inv".
- src/routes/launchpad.tsx: exclude Unassigned from the type list.
