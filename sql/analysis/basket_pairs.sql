-- ============================================================
-- S04 BASKET ANALYSIS : product pairs and order profiles
-- ============================================================
-- Purpose: answer which products are bought together and which
-- order profiles matter operationally.
--
-- Grain used: fact_sales has one row per order line.
-- Pattern: self-join fact_sales on order_number, with product_key <
-- product_key to avoid duplicate pairs and self-pairs.
-- ============================================================

-- ------------------------------------------------------------
-- 1. Top product pairs bought together
-- ------------------------------------------------------------
SELECT
    pa.product_id AS product_a_id,
    pa.product_name AS product_a_name,
    pa.category AS product_a_category,
    pb.product_id AS product_b_id,
    pb.product_name AS product_b_name,
    pb.category AS product_b_category,
    COUNT(DISTINCT f1.order_number) AS baskets_together,
    ROUND(SUM(f1.line_total + f2.line_total), 2) AS pair_line_revenue
FROM fact_sales f1
JOIN fact_sales f2
    ON f1.order_number = f2.order_number
   AND f1.product_key < f2.product_key
JOIN dim_product pa
    ON pa.product_key = f1.product_key
JOIN dim_product pb
    ON pb.product_key = f2.product_key
GROUP BY
    pa.product_id, pa.product_name, pa.category,
    pb.product_id, pb.product_name, pb.category
ORDER BY baskets_together DESC, pair_line_revenue DESC
LIMIT 20;

-- ------------------------------------------------------------
-- 2. Cross-category basket patterns
-- ------------------------------------------------------------
SELECT
    pa.category AS category_a,
    pb.category AS category_b,
    COUNT(DISTINCT f1.order_number) AS baskets_together,
    ROUND(SUM(f1.line_total + f2.line_total), 2) AS pair_line_revenue
FROM fact_sales f1
JOIN fact_sales f2
    ON f1.order_number = f2.order_number
   AND f1.product_key < f2.product_key
JOIN dim_product pa
    ON pa.product_key = f1.product_key
JOIN dim_product pb
    ON pb.product_key = f2.product_key
WHERE pa.category < pb.category
GROUP BY pa.category, pb.category
ORDER BY baskets_together DESC, pair_line_revenue DESC;

-- ------------------------------------------------------------
-- 3. Operational order profiles from the junk dimension
-- ------------------------------------------------------------
SELECT
    op.profile_name,
    COUNT(DISTINCT f.order_number) AS orders,
    COUNT(*) AS order_lines,
    ROUND(SUM(f.line_total), 2) AS revenue,
    ROUND(AVG(f.line_total), 2) AS avg_line_total
FROM fact_sales f
JOIN dim_order_profile op
    ON op.order_profile_key = f.order_profile_key
GROUP BY op.profile_name
ORDER BY orders DESC, revenue DESC
LIMIT 20;

-- ------------------------------------------------------------
-- 4. S04 validation checks
-- ------------------------------------------------------------
-- 4.1 fact_sales keeps the expected grain.
SELECT
    'duplicate_fact_sales_grain' AS check_name,
    COUNT(*) AS duplicate_grains,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT order_number, sale_line_id, COUNT(*) AS n
    FROM fact_sales
    GROUP BY order_number, sale_line_id
    HAVING COUNT(*) > 1
);

-- 4.2 every fact row has an order profile key.
SELECT
    'null_order_profile_key' AS check_name,
    COUNT(*) AS null_keys,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales
WHERE order_profile_key IS NULL;

-- 4.3 every order profile key points to the junk dimension.
SELECT
    'orphan_order_profile_key' AS check_name,
    COUNT(*) AS orphan_keys,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales f
LEFT JOIN dim_order_profile op
    ON op.order_profile_key = f.order_profile_key
WHERE op.order_profile_key IS NULL;

-- 4.4 adding the junk-dimension key did not drop fact rows.
SELECT
    'fact_sales_row_reconciliation' AS check_name,
    (SELECT COUNT(*) FROM raw_fact_sales) AS raw_rows,
    (SELECT COUNT(*) FROM fact_sales) AS fact_rows,
    CASE
        WHEN (SELECT COUNT(*) FROM raw_fact_sales) = (SELECT COUNT(*) FROM fact_sales)
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result;

-- 4.5 basket-pair logic does not produce self-pairs.
SELECT
    'basket_pairs_no_self_pairs' AS check_name,
    COUNT(*) AS self_pairs,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales f1
JOIN fact_sales f2
    ON f1.order_number = f2.order_number
   AND f1.product_key < f2.product_key
WHERE f1.product_key = f2.product_key;

-- 4.6 summary counts for reporting.
SELECT
    COUNT(*) AS fact_rows,
    COUNT(DISTINCT order_number) AS orders,
    COUNT(DISTINCT order_profile_key) AS profiles_used,
    COUNT(*) FILTER (WHERE order_profile_key IS NULL) AS null_profile_keys
FROM fact_sales;
