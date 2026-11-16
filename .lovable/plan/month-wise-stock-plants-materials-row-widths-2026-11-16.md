# Month Wise Stock: Plants/Materials row widths

On wide screens, the row becomes a 12-part layout. Top 15 Plants takes 8 parts (about two-thirds of the width) and Top 10 Materials takes 4 parts (about one-third). On smaller screens the two cards stack.

Technical: in month-wise-stock-dashboard.tsx, change that row's grid to `grid-cols-1 lg:grid-cols-12`. Wrap the plants card in `lg:col-span-8` and the materials card in `lg:col-span-4`.
