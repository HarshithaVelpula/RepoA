# ZKEYRM Comparison: Month Wise Stock same as Purchase Register

## Current state
- After the last change, Month Wise Stock uses exactly the same ZKEYRM Comparison card as Purchase Register: Total Procurement Value and PO Val in ₹ Cr, and Unit Price, Avg Price, vs prev month, Diff from first and the chart in plain ₹, all with 2 decimals.

## Fix to add (both screens)
- The numbers on the chart's left axis get cut off when they're large (e.g. ",33,650.00"). Widen that axis so the full number shows, for example 7,33,650.00.

## Technical details
- In `src/components/zrmmat-compare-card.tsx`, give the `<YAxis>` a width based on its longest label (about 6px per character, at least 60px).
- Upload the new frontend build to Quality to see it there.
