# Daily Production Report: correct SAP dates and add Plant Short Name

## What's wrong now
- In SAP API Settings, the Daily_Production_Report date pickers write **BUDAT_F / BUDAT_T** into the payload, as the Sales screens do. ZDPR only uses **FROMDT / TODT** (format YYYY-MM-DD), so the two extra keys are wrong.
- The new SAP reply includes **PLANT_SHORT_NAME** (for example 1105 → NCFP). The app doesn't store or show it yet.

## Changes
1. **SAP API Settings (Daily_Production_Report only)**
   - The From and To pickers read and write FROMDT and TODT, in YYYY-MM-DD. The hint under each one will say "Sent as FROMDT (YYYY-MM-DD)".
   - The preset date range (Current date, Last 1 month, and so on) fills FROMDT and TODT.
   - BUDAT_F and BUDAT_T are removed from this endpoint's payload. Your saved FROMDT 2026-04-01 and TODT 2026-11-18 are kept when the range is Custom.
   - Each sync still sends the dates from the chosen range, as it does today.
2. **Store Plant Short Name**
   - Add a Plant Short Name field to the daily production data and save PLANT_SHORT_NAME on every sync.
3. **Use the Plant Short Name everywhere instead of the plant code**
   - On the Daily Production Report, the plant short name (e.g. NCFP) replaces the plant code: Plant filter, Plant Wise Production chart, tooltips, detail table, Excel and PDF.
   - If a row has no short name yet, the code is shown instead.
   - Filtering still matches on the code behind the scenes, so plant access rights are unchanged.

## Technical details
- Migration: `ALTER TABLE public.daily_production ADD COLUMN IF NOT EXISTS plant_short_name text`, backfilled from `raw->>'PLANT_SHORT_NAME'`, then `NOTIFY pgrst`. The migration is mirrored in supabase/migrations.
- `daily-production-map.ts`: map PLANT_SHORT_NAME (also accept PLANTSHORTNAME).
- `daily-production-data.ts`: add `plantName`; display uses plantName || plant. Bump the query key to v2.
- `sap-api.tsx`: in `withDefaultDates` and in the date-field key selection, add a branch for `isDailyProductionEndpoint` that uses the keys FROMDT/TODT with ISO date values and strips BUDAT_F/BUDAT_T.
- Rebuild `middleware/sync-core.mjs`.
- On Quality and Production: run the migration, copy sync-core.mjs, run `pm2 restart`, and upload the new build.
