# Month Wise Stock: Plant and Type filters

1. **Plant filter**: the list shows plant names from PCGRP3 (the same names used in the Top 15 Plants card). If a plant has no PCGRP3, its code is shown. You can tick several plants.
2. **Type filter**: you can tick several types (with Select all).
3. **Material Group filter**: removed.
4. Unticked or Select all means every value. Reset clears Plant and Type and goes back to the current month.

Technical: in month-wise-stock-dashboard.tsx, change F to `{ plants: string[] | null; types: string[] | null }`. Plant options and matching use `r.sub3 || r.plant`. Both filters render with FilterMultiSelect in the same way as Month. Drop matGroup from the filter state and options. The detailed table keeps its Material Group column.
