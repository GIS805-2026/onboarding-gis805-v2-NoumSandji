SHOW TABLES;
DESCRIBE raw_dim_product;
DESCRIBE raw_fact_sales;
DESCRIBE raw_dim_date;
DESCRIBE raw_dim_store;
DESCRIBE raw_orders;
DESCRIBE raw_dim_channel;
SELECT *
FROM raw_dim_product;
SELECT DISTINCT category
FROM raw_dim_product;
SELECT DISTINCT region
FROM raw_dim_store
order by region;
SELECT *
FROM raw_fact_sales
LIMIT 5;
SELECT COUNT(*)
FROM raw_fact_sales;
select *
from raw_dim_date
LIMIT 20;
SELECT COUNT(*)
FROM raw_fact_sales
WHERE store_id NOT IN (
    SELECT store_id
    FROM raw_dim_store
  );
SELECT p.category,
  s.region,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  SUM(f.quantity) AS total_quantity,
  AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
  JOIN raw_dim_product p ON p.product_id = f.product_id
  JOIN raw_dim_store s ON s.store_id = f.store_id
  JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category,
  s.region
ORDER BY revenue DESC
LIMIT 20;
SELECT p.category,
  COUNT(*) AS n_lines,
  SUM(s.line_total) AS revenue
FROM raw_fact_sales s
  JOIN raw_dim_product p ON p.product_id = s.product_id
GROUP BY p.category
ORDER BY revenue DESC;
SELECT MIN(order_date) AS first_sale,
  MAX(order_date) AS last_sale,
  COUNT(DISTINCT order_date) AS n_distinct_days
FROM raw_fact_sales;
SELECT p.category,
  p.brand,
  SUM(f.line_total) AS revenue,
  SUM(f.quantity) AS qty,
  AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
  JOIN raw_dim_product p ON p.product_id = f.product_id
GROUP BY p.category,
  p.brand
ORDER BY revenue DESC
LIMIT 10;
SELECT p.category,
  s.region,
  d.month_name,
  AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
  JOIN raw_dim_product p ON p.product_id = f.product_id
  JOIN raw_dim_store s ON s.store_id = f.store_id
  JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category,
  s.region,
  d.month_name
ORDER BY revenue DESC
LIMIT 20;
SELECT p.category,
  s.region,
  d.month_name,
  AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
  JOIN raw_dim_product p ON p.product_id = f.product_id
  JOIN raw_dim_store s ON s.store_id = f.store_id
  JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category,
  s.region,
  d.month_name
ORDER BY revenue ASC
LIMIT 20;
SELECT p.category,
  s.region,
  AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
  JOIN raw_dim_product p ON p.product_id = f.product_id
  JOIN raw_dim_store s ON s.store_id = f.store_id
  JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category,
  s.region
ORDER BY revenue DESC
LIMIT 20;
SELECT p.category,
  s.region,
  d.quarter,
  -- AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  -- AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
  JOIN raw_dim_product p ON p.product_id = f.product_id
  JOIN raw_dim_store s ON s.store_id = f.store_id
  JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category,
  s.region,
  d.quarter
ORDER BY revenue DESC
LIMIT 20;
SELECT p.category,
  s.region,
  d.quarter,
  -- AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  -- AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
  JOIN raw_dim_product p ON p.product_id = f.product_id
  JOIN raw_dim_store s ON s.store_id = f.store_id
  JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category,
  s.region,
  d.quarter
ORDER BY revenue ASC,
  d.quarter ASC
LIMIT 10;
SELECT p.category,
  s.region,
  d.quarter,
  -- AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  -- AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
  JOIN raw_dim_product p ON p.product_id = f.product_id
  JOIN raw_dim_store s ON s.store_id = f.store_id
  JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category,
  s.region,
  d.quarter
ORDER BY revenue DESC,
  d.quarter ASC
LIMIT 30;