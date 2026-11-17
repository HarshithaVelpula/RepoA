# Fast Month Wise Stock screen and launchpad

## Why it is slow
Both the screen and the launchpad card download every uploaded row for every month (60,000+ per month), 1,000 rows at a time, one request after another. Production has more months stored, so it takes much longer.

## Fix
1. Database summary function `month_wise_stock_summary(months)`: totals grouped in the database by month, valuation class, profit centre, plant, material. It returns a few thousand summary lines instead of lakhs of raw rows. It respects the same access rules.
2. Launchpad card: calls a tiny function `month_wise_stock_latest_total()` that returns only the latest month total and its top types. It loads in under a second.
3. Screen: loads the summary first, so tiles, cards and charts show quickly. The detailed table loads page by page from the database (50 rows per page, with search). Excel downloads the full rows only when clicked.
4. Index on (year, month) already exists. Add an index on the valuation class and profit centre values inside the data.
5. Mirror the migration in supabase/migrations so you can run it on Quality and Production.

## Unchanged
Numbers, filters (Month, Plant, Type), the total-row exclusion, ZKEYRM Comparison, Last 3 Months Comparison and the PDF stay the same. Data still refreshes only when you click Refresh.

## Technical
- RPC returns rows aggregated by (year, month, ValCl, Profit Centre, Plant, Material) with sum(CB Qty) and sum(CB Val), excluding rows with empty ValCl (the total row).
- mapStockRows works on aggregated rows; existing tests are kept.
- The table uses a paged RPC similar to month_wise_upload_page.
