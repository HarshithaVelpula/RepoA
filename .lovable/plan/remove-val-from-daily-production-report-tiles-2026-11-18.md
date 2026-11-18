# Remove "Val" from Daily Production Report tiles

On the Daily Production Report, change the tile labels:
- "Production Val" becomes "Production"
- "Scrap Val" becomes "Scrap"

Nothing else changes: the other tiles, the card headings ("Val in Cr"), the chart tooltip, the table and Excel stay the same.

## Technical details
- In src/components/daily-production-dashboard.tsx, edit only the tile label strings on lines 80 and 82.
