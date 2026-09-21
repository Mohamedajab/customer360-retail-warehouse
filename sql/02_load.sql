INSERT INTO dim_customer (customer_id, customer_name, email, region, joined_date)
SELECT customer_id, customer_name, email, region, joined_date FROM stage_customers;

INSERT INTO dim_product (product_id, product_name, category, standard_cost)
SELECT product_id, product_name, category, standard_cost FROM stage_products;

INSERT INTO fact_sales (
    line_id, order_id, date_key, customer_key, product_key, quantity, unit_price,
    returned_quantity, gross_revenue, return_value, net_revenue
)
SELECT
    t.line_id, t.order_id, CAST(REPLACE(t.order_date, '-', '') AS INTEGER),
    c.customer_key, p.product_key, t.quantity, t.unit_price, t.returned_quantity,
    ROUND(t.quantity * t.unit_price, 2),
    ROUND(t.returned_quantity * t.unit_price, 2),
    ROUND((t.quantity - t.returned_quantity) * t.unit_price, 2)
FROM stage_transactions t
JOIN dim_customer c ON c.customer_id = t.customer_id
JOIN dim_product p ON p.product_id = t.product_id
JOIN dim_date d ON d.full_date = t.order_date;

