# Fast Month Wise Stock screen and launchpad

## Why it is slow
Both the screen and the launchpad card download every uploaded row for every month (60,000+ per month) in 1,000-row batches, one after another. Production stores more months, so it is much slower there.

## Fix (filter by the Month and Year columns)
1. **Launchpad card:** reads only the latest uploaded month, already totalled in the database. It shows the ₹ Cr total and the top types almost instantly.
2. **Screen opens fast:** the tiles, Top 10 Types, Top 15 Plants, Top 10 Materials, Main/Sub Group cards and the table load only the latest selected month. This is a single month's data, filtered by Month and Year.
3. **Month Wise Inventory and Last 3 Months Comparison:** these load separately, after the rest of the screen is showing, using small month-by-type totals from the database. Each card shows its own loading spinner, so the rest of the screen never waits for them.
4. **ZKEYRM Comparison:** uses the same month totals per material, not the raw rows.
5. **Detailed table:** pages of 50 rows from the database, with search. Excel downloads the full month only when you click it.

## Unchanged
The numbers, the Month/Plant/Type filters, the Excel total-row exclusion and the PDF stay the same. Data still refreshes only when you click Refresh.

## Technical
- New RPCs (security invoker, same RLS): `month_wise_stock_months()` (the list of month/year values), `month_wise_stock_rows(_month,_year)` (one month's rows, skipping empty ValCl), and `month_wise_stock_totals()` (sum CB Val/CB Qty grouped by year, month, ValCl, Profit Centre, Material).
- Index on (year, month) is already present.
- Query keys per month: ["month-wise-stock","month",y,m] and ["month-wise-stock","totals"]. The launchpad uses the latest-month query.
- Mirror the migration in supabase/migrations for Quality and Production.
