# Month Wise Stock: Plant filter by plant code

## Problem
The Plant dropdown mixes plant codes (1000, 1100...) with group names (BRACH, CORP, NCPP). Cards and tiles use the group name (Sub Group 3) when it exists, so picking a code like 1000 matches almost no rows and everything shows 0.00.

## Fix
- Plant dropdown lists each plant code once, shown as "1000 - <plant name>" (name from Sub Group 3 when available, else code only).
- Selecting a plant filters by the plant code on every part of the screen: tiles, Month Wise Inventory, Last 3 Months, Top 10 Types, group cards, Top 15 Plants, Top 10 Materials, ZKEYRM Comparison and the detail table.
- Top 15 Plants chart keeps showing names as today.

## Technical details
- In month-wise-stock-dashboard.tsx: options built as `{ value: r.plant, label: name ? `${r.plant} - ${name}` : r.plant }` (unique by code); all filter predicates compare `r.plant` instead of `plantName(r)`.
- Check tiles use the filtered rows (not unfiltered RPC totals) when a plant is selected.
