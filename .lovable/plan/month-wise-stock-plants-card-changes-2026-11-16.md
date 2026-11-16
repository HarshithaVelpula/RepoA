# Month Wise Stock: Plants card changes

1. Remove the "Top 10 Material Groups" card.
2. Rename "Top 10 Plants" to "Top 15 Plants" and show 15 bars.
3. Plant names come from PCGRP3 (Sub Group 3 in the ZPC GROUP master, looked up by Profit Centre). If a row has no PCGRP3, the plant code is shown instead.

Technical: in month-wise-stock-dashboard.tsx, delete groupCard("Top 10 Material Groups"). The plant chart uses sumBy(cur, r => r.sub3 || r.plant).slice(0, 15), with 15 gradient defs (mws-p0..14) and x-axis labels angled so they fit. Filters and the table stay the same.
