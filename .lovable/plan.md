# Current Stock: support the new SAP field names

## What changes
- Read the new SAP keys, with the old ones as fallback:
  - Unrestricted value/qty: UNRESTRICTED_VALUE / UNRESTRICTED_QTY (else WLABS / LABST)
  - Stk in QC value/qty: QC_VALUE / QC_QTY (else WINSM / INSME)
  - Blocked value/qty: BLOCKED_VALUE / BLOCKED_QTY (else WSPEM / SPEME)
- If all three values are 0 but WBWBEST has a value, use WBWBEST as Unrestricted so the total is not lost.
- Store the new fields too: MBWBEST, WBWBEST, BKLAS, BKBEZ, VALCLASS_SN, MATKL, MTART, HWAER.
- Trim leading zeros from material numbers (000000009500000552 -> 9500000552).
- Missing storage location / batch are stored as empty, so each plant + material is one line.
- Existing synced rows are recalculated from their saved SAP data, so a re-sync is not required.

## Technical details
- src/lib/current-stock-map.ts: alias list per typed field, WBWBEST fallback, MATNR zero-trim.
- New migration (mirrored in supabase/migrations) adding the new columns and backfilling numeric columns from raw.
- Bump current-stock query key so cached zero values are dropped.
- Rebuild middleware/sync-core.mjs; small vitest for alias + fallback + zero-trim.

## Deploy for Quality / Production
Run the migration, copy sync-core.mjs, pm2 restart MIS_QTY, upload build, click Sync.
