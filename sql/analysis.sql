-- Which regions are growing between the first and second quarter?
WITH regional_quarter AS (
  SELECT c.region, d.quarter_number, SUM(f.net_revenue) AS revenue
  FROM fact_sales f
  JOIN dim_customer c ON c.customer_key = f.customer_key
  JOIN dim_date d ON d.date_key = f.date_key
  GROUP BY c.region, d.quarter_number
)
SELECT region,
  SUM(CASE WHEN quarter_number = 1 THEN revenue ELSE 0 END) AS q1_revenue,
  SUM(CASE WHEN quarter_number = 2 THEN revenue ELSE 0 END) AS q2_revenue
FROM regional_quarter GROUP BY region;

-- Which products combine strong revenue with a low return rate?
SELECT product_name, category, units_sold, units_returned, net_revenue,
       ROUND(100.0 * units_returned / NULLIF(units_sold, 0), 1) AS return_rate_pct
FROM vw_product_performance
ORDER BY net_revenue DESC;

-- How much value comes from customers who have returned for another order?
SELECT is_returning_customer, COUNT(*) AS customers, ROUND(SUM(lifetime_value), 2) AS value
FROM vw_customer_summary GROUP BY is_returning_customer;

