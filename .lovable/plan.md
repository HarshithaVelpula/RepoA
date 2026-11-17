# Month Wise Stock: lock the current month in the Month filter

## What changes
- The current month (or, if it has no data yet, the latest earlier month — e.g. Oct-2026 when Nov isn't uploaded) always stays ticked in the Month dropdown.
- Unticking it is blocked and a message appears: "Oct-2026 is the latest month and can't be unchecked."
- "Deselect All" keeps the latest month ticked (and shows the same message); "Select All" works as now.
- Other months can still be ticked/unticked freely, so Month Wise Inventory still compares them, while all other cards keep showing the latest month.
- Reset returns to only the latest month.

## Technical details
- In month-wise-stock-dashboard.tsx, wrap the Month onChange: if the new selection lacks the locked period (defaultPeriod result), re-add it and show a sonner toast warning.
- Locked month also forced when the current selection is null/"all" (no change needed there).
