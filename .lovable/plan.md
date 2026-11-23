# Distribution Channel card: full names, no scroll

## What changes
- The donut moves to the top of the card, and the channel list goes below it at the full card width, using the empty space at the bottom.
- Each channel shows its full name (for example "01 — Domestic Sales"). Long names wrap onto a second line instead of being cut with "…".
- The list has no height limit, so the scroll bar disappears and every channel stays visible. Value (₹ Cr) and % stay right-aligned on each line.
- Your screenshot shows codes like ZDOR/ZSOR. Those are order types from the earlier version; after a Refresh the list groups by channel (01 Domestic, 02 Export, 03 Deemed Export, 04 SEZ, 06 Dealer), so it stays short.
- The PDF shows the same layout.

## Technical details
- `sales-register-dashboard.tsx` Donut: add a `stacked` mode used only by the Distribution Channel card. The donut sits centred above the list, the `max-h`/`overflow-auto` on the list is removed, and `truncate` is replaced with `break-words`. Other donuts are unchanged.
