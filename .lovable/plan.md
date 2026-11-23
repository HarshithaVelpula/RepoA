# Make Distribution Channel match Net Value

## Why they differ
- **Net Value tile (₹ 2,279 Cr)** adds NETWR_EX (value **without** tax).
- **Distribution Channel card (₹ 2,340 Cr)** adds NETWR_T (value **with** tax/other charges, ~₹ 61 Cr more).
- So both are correct sums, but of two different SAP fields. It was like this before today's change; today only the ₹ values were made visible, which exposed the difference.
- Production shows the same because the screen reads the same stored Sales Register rows there.

## Fix
- Distribution Channel card: sum NETWR_EX per channel and use the Net Value total in the centre, so 01 + 02 + 03 + 04 + 06 = ₹ 2,279 Cr exactly.
- Check the other cards (Plant, Customers, Profit Centres, Materials, Main Group) use the same Net Value; switch any that use the with-tax value.
- Launchpad Sales Register tile already uses NETWR_EX — no change.
- Add a small test: channel totals add up to the Net Value total.
- Production: after this is published / static build is redeployed (dist upload), a Refresh shows the matching numbers. No SAP sync needed.

## Table and Excel
- Sales Register detailed table and Excel: add an **Invoice Value (₹)** column (NETWR_T, with tax), full ₹ values, next to Net Value (₹) (NETWR_EX). The totals row adds it too.
