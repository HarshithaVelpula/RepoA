# Distribution Channel card: names and values only

## What changes
- Each line shows only the channel name and its value, for example "Domestic Sales — ₹ 329.28 Cr".
- The code ("01 —") and the percentage ("· 82.3%") are removed.
- The donut and the total in its centre stay the same, and the PDF follows the screen.
- The table, the Excel file and the filters are unchanged.

## Technical details
- `sales-register.ts`: `byChannel` groups by the channel description only (`r.channel || r.channelCode`).
- `sales-register-dashboard.tsx`: the `showBoth` legend line drops the `· %` part.
- Update `sales-register.test.ts` if it relies on the channel label.
