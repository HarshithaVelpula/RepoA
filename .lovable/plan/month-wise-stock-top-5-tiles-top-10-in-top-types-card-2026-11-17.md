# Month Wise Stock: top 5 tiles, top 10 in Top Types card

- **Tiles:** Total Inv plus only the top 5 types by value (e.g. Raw material, SFG, Imported, Ancillary, FG). Smaller types no longer get their own tile.
- **Top Types card:** renamed "Top 10 Types". It shows the top 10 types. Any remaining types stay behind the "Others" button and open in the popup, as they do now.

## Technical details
- In month-wise-stock-dashboard.tsx, limit the type tiles to `types.slice(0, 5)`.
- The card calls `topWithOthers(types, 10)`, with the title changed to "Top 10 Types".
- The launchpad and PDF stay unchanged.
