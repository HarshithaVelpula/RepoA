# Distribution Channel card: full names, no scroll (side by side)

## What changes
- The donut stays on the left and the channel list stays on the right, side by side.
- The list uses the card's full height, including the empty space at the bottom, and has no height limit, so the scroll bar disappears.
- Full channel names (for example "01 — Domestic Sales") wrap onto two lines instead of being cut with "…". Value (₹ Cr) and % sit on their own line under the name, so the name gets the full width.
- Your screenshot shows codes like ZDOR/ZSOR. Those are order types from the earlier version; after a Refresh the list groups by channel (01 Domestic, 02 Export, 03 Deemed Export, 04 SEZ, 06 Dealer), so it stays short.
- The PDF shows the same layout.

## Technical details
- `sales-register-dashboard.tsx` Donut: for `showBoth`, remove `max-h-[140px] overflow-auto`, replace `truncate` with `break-words`, and put the value/% on a second line. Other donuts are unchanged.
