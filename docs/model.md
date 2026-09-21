# Model notes

```mermaid
erDiagram
  DIM_DATE ||--o{ FACT_SALES : date_key
  DIM_CUSTOMER ||--o{ FACT_SALES : customer_key
  DIM_PRODUCT ||--o{ FACT_SALES : product_key
  DIM_DATE { int date_key PK }
  DIM_CUSTOMER { int customer_key PK string customer_id UK }
  DIM_PRODUCT { int product_key PK string product_id UK }
  FACT_SALES { int sales_key PK string line_id UK decimal net_revenue }
```

The fact grain is one product line on an order. Revenue and returns therefore aggregate
correctly by product, customer, region and date. `order_id` is intentionally degenerate:
it is useful for distinct-order measures but does not merit its own dimension.

Customer and product dimensions use surrogate keys so a later warehouse can adopt slowly
changing dimensions without rewriting the fact contract. This demonstration uses current
attributes (type 1) because the source does not provide change history.

