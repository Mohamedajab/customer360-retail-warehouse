CREATE VIEW vw_monthly_performance AS
SELECT
    d.year_number, d.month_number, d.month_name,
    COUNT(DISTINCT f.order_id) AS orders,
    COUNT(DISTINCT f.customer_key) AS active_customers,
    ROUND(SUM(f.gross_revenue), 2) AS gross_revenue,
    ROUND(SUM(f.return_value), 2) AS return_value,
    ROUND(SUM(f.net_revenue), 2) AS net_revenue,
    ROUND(100.0 * SUM(f.returned_quantity) / NULLIF(SUM(f.quantity), 0), 1) AS return_rate_pct
FROM fact_sales f JOIN dim_date d ON d.date_key = f.date_key
GROUP BY d.year_number, d.month_number, d.month_name;

CREATE VIEW vw_customer_summary AS
SELECT
    c.customer_id, c.customer_name, c.region,
    COUNT(DISTINCT f.order_id) AS lifetime_orders,
    MIN(d.full_date) AS first_order_date, MAX(d.full_date) AS latest_order_date,
    ROUND(SUM(f.net_revenue), 2) AS lifetime_value,
    CASE WHEN COUNT(DISTINCT f.order_id) > 1 THEN 1 ELSE 0 END AS is_returning_customer
FROM dim_customer c
LEFT JOIN fact_sales f ON f.customer_key = c.customer_key
LEFT JOIN dim_date d ON d.date_key = f.date_key
GROUP BY c.customer_key, c.customer_id, c.customer_name, c.region;

CREATE VIEW vw_product_performance AS
SELECT
    p.product_id, p.product_name, p.category,
    SUM(f.quantity) AS units_sold, SUM(f.returned_quantity) AS units_returned,
    ROUND(SUM(f.net_revenue), 2) AS net_revenue,
    ROUND(SUM((f.unit_price - p.standard_cost) * (f.quantity - f.returned_quantity)), 2) AS gross_margin
FROM dim_product p LEFT JOIN fact_sales f ON f.product_key = p.product_key
GROUP BY p.product_key, p.product_id, p.product_name, p.category;

