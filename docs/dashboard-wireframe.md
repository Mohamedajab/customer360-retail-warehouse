# Dashboard wireframe

```text
┌──────────────────────────────────────────────────────────────┐
│ Customer360     [Date] [Region] [Category]                  │
├──────────────┬──────────────┬──────────────┬────────────────┤
│ Net revenue  │ Orders       │ Return rate  │ Returning cust │
├─────────────────────────────┬────────────────────────────────┤
│ Monthly net revenue         │ Revenue by region              │
│ (line, prior period tooltip)│ (sorted horizontal bars)       │
├─────────────────────────────┼────────────────────────────────┤
│ Product revenue & returns   │ Customer cohort/detail         │
│ (matrix with conditional fmt)│ (drill-through target)        │
└─────────────────────────────┴────────────────────────────────┘
```

The first screen answers performance questions without making users interpret warehouse
terminology. A product drill-through shows units, net revenue, margin and return rate. A
customer drill-through shows first/latest order, lifetime value and order count. Totals
should be validated against the SQL views before publishing.

