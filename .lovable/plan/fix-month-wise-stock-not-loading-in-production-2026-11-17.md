# Fix Month Wise Stock not loading in Production

## What is happening
Your screenshot shows the launchpad call `month_wise_stock_kpis` running for 1 minute and then failing with **504 (timeout)**. So the database function is installed, but it is too slow on Production's data, and the card stays on "...". The screen uses the same kind of query, so it gets stuck the same way.

Why it is slow:
1. **Every month, every row is read.** Production has several months of about 60,000 rows each. Each time it adds them all up, it reads numbers out of the raw Excel text and cleans them.
2. **The access check runs on every row.** The "who can see this plant / profit centre" check runs once per row, hundreds of thousands of times, instead of once per user.

Together these go past the 60-second limit, and the server gives up.

## The fix
1. **Store the key numbers as real columns at upload time.** The database keeps Valuation Class, Profit Centre, Plant, Material, CB Qty and CB Val as their own columns, filled in automatically from the Excel data. Existing rows get them too. Totals then add plain numbers and skip the text cleaning.
2. **Check access once per request, not per row.** The summary functions check your role and plant / profit centre access one time, then filter by it. Users still see only their own plants and profit centres.
3. **The launchpad reads one month only.** First it gets the list of uploaded months (instant). Then it adds up only the default month: the current month, or the latest earlier month if the current one isn't uploaded.
4. **The screen:** tiles and cards add up only the shown month. Month Wise Inventory and Last 3 Months Comparison use small month-by-type totals. Top 10 Materials and ZKEYRM read only the months they need.
5. **No endless "...".** If a total fails to load, the card shows "Couldn't load – Refresh" instead of spinning forever.

Expected result: the launchpad card and screen load in about 1–2 seconds, even with 1 lakh rows per month.

## For Quality and Production
1. Run the new database file (one file in `supabase/migrations`). It also fills the new columns for data already uploaded. This may take a minute on Production.
2. Upload the new frontend build and hard refresh.

## Technical details
- Migration: add STORED generated columns on `month_wise_upload`: `val_class`, `profit_centre`, `plant`, `material`, `cb_qty`, `cb_val`. They are built from `trim(data->>...)` and the immutable `mws_num()`. Add the index `(year, month, val_class)`.
- Rewrite `month_wise_stock_kpis(_year,_month)`, `month_wise_stock_summary()` and `month_wise_stock_materials(_mats, _periods)` as SECURITY DEFINER with `search_path=public`.
  - Up front, check `has_screen(auth.uid(),'inv.month-wise-stock') OR is_data_admin` once, then read `current_access_unrestricted()`, plants and profit centres into variables.
  - Filter with `unrestricted OR plant = ANY(...) OR profit_centre = ANY(...)`, using the typed columns.
  - Add a new `month_wise_stock_months()` that returns distinct year/month.
- Revoke from public/anon, grant to authenticated, `NOTIFY pgrst`.
- `month-wise-stock-data.ts`: launchpad calls months, then the kpis for `defaultPeriod`. Bump the query keys to `v5`. `launchpad.tsx` shows an error state instead of `...`.
- Mirror the migration in `supabase/migrations` and drizzle.
- Check the speed with EXPLAIN on a test load of about 200k rows here before handing over.
