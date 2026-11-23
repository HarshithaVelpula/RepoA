# Current Stock launchpad card: show Stock Status values

The Current Stock card on the launchpad will show the same stock status types as the "Stock Status" card on the screen:
- **Current Inv Val (₹ Cr):** the main figure, Unrestricted + Stk in QC + Blocked
- One line each for **Unrestricted**, **Stk in QC** and **Blocked**, with value in ₹ Cr
- **Last Sync** time (India time) at the bottom

It keeps the Inventory green radiant style and the "Open" button. Types with zero value are hidden, as they are on the screen. The figures change only when someone clicks Refresh or Sync on the screen.

## Technical details
- `launchpad.tsx`: add `CurrentStockTile` for screen key `inv.current-stock`. It uses `currentStockQuery`, the same stable query the screen uses, with `stockTotals` and the `TableStatusTile` layout with accent 5.
- Show Last Sync from the newest `synced_at` in the loaded rows, adding it to the row mapping if it isn't already there.
