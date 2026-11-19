# Replace Daily Production data with the new file

- Delete all 2,891 rows that are in Daily Production now.
- Load all 17,462 rows from ZDPR_Data-2.txt. They cover posting dates 02-04-2026 to 10-06-2026, and every row has a plant short name.
- Fill in the plant short name for every row, so the screen shows names such as NCFP instead of plant codes.
- Afterwards, check the number of rows, the date range and the total value.

Only the data changes. No changes are made to how the screen looks or works.

## Technical details
- Run `DELETE FROM public.daily_production WHERE mblnr IS NOT NULL` through the data tool.
- Load the rows with the same mapping script used for the last import (typed columns plus raw, including plant_short_name), then `\copy` them into the table.
