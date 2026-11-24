# Production by Work Center: Top 10

On the Daily Production Report, the "Production by Work Center" card will show only the top 10 work centers by production value, in the donut and in its table. The card title becomes "Top 10 Work Centers".

Nothing else changes: the tiles, other cards, totals, detail table and Excel stay as they are.

## Technical details
- In `daily-production-dashboard.tsx`, change `const wcs = dprGroup(data, (r) => r.wcDesc)` to add `.slice(0, 10)`, and update the card title.
