# Remove the User column from the Daily Production Report

On the Daily Production Report, remove the "User" column from the detail table and from the Excel download. The other columns, the totals row, search and pagination stay the same.

## Technical details
- In `daily-production-dashboard.tsx`, drop "User" from `HEADS` and `r.user` from `cells`. Adjust the footer `colSpan` after Scrap Val from 5 to 4.
