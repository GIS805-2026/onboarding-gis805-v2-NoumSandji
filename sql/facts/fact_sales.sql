-- ============================================================
-- FACT_SALES : sales fact table with explicit grain
-- ============================================================
-- GRAIN : one row = one order line identified by
--         (order_number, sale_line_id).
--
-- Degenerate dimension: order_number.
-- Foreign keys: date_key, customer_key, product_key, store_key, channel_key.
-- Measures: quantity, unit_price, discount_pct, net_price, line_total,
--           gross_amount, margin_amount.
-- ============================================================

CREATE OR REPLACE TABLE fact_sales AS
SELECT
    -- Grain identifiers / degenerate dimension
    f.order_number,
    f.sale_line_id,

    -- Dimension foreign keys
    d.date_key,
    c.customer_key,
    p.product_key,
    s.store_key,
    ch.channel_key,

    -- Natural keys kept for traceability
    f.order_date,
    f.customer_id,
    f.product_id,
    f.store_id,
    f.channel_id,

    -- Measures
    CAST(f.quantity AS INTEGER)           AS quantity,
    CAST(f.unit_price AS DECIMAL(12, 2))  AS unit_price,
    CAST(f.discount_pct AS DECIMAL(5, 4)) AS discount_pct,
    CAST(f.net_price AS DECIMAL(12, 2))   AS net_price,
    CAST(f.line_total AS DECIMAL(12, 2))  AS line_total,

    -- Derived measures
    CAST(f.quantity * f.unit_price AS DECIMAL(12, 2)) AS gross_amount,
    CAST((f.net_price - p.unit_cost) * f.quantity AS DECIMAL(12, 2)) AS margin_amount,
    CURRENT_DATE AS loaded_at
FROM raw_fact_sales f
JOIN dim_date d
    ON d.date_key = f.order_date
JOIN dim_customer c
    ON c.customer_id = f.customer_id
JOIN dim_product p
    ON p.product_id = f.product_id
JOIN dim_store s
    ON s.store_id = f.store_id
JOIN dim_channel ch
    ON ch.channel_id = f.channel_id;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Grain uniqueness: (order_number, sale_line_id) must be unique.
SELECT
    'fact_sales_grain_unique' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT (order_number || '-' || sale_line_id::VARCHAR))
         THEN 'PASS' ELSE 'FAIL -- duplicate grain' END AS result
FROM fact_sales;

-- 2. No NULL surrogate foreign keys.
SELECT
    'fact_sales_no_null_keys' AS check_name,
    CASE WHEN COUNT(*) FILTER (
        WHERE date_key IS NULL
           OR customer_key IS NULL
           OR product_key IS NULL
           OR store_key IS NULL
           OR channel_key IS NULL
    ) = 0 THEN 'PASS' ELSE 'FAIL -- NULL surrogate key' END AS result
FROM fact_sales;

-- 3. Reconcile row count with the source.
SELECT
    'fact_sales_reconcile_rowcount' AS check_name,
    (SELECT COUNT(*) FROM raw_fact_sales) AS source_rows,
    (SELECT COUNT(*) FROM fact_sales)     AS fact_rows,
    CASE WHEN (SELECT COUNT(*) FROM fact_sales) = (SELECT COUNT(*) FROM raw_fact_sales)
         THEN 'PASS' ELSE 'INVESTIGATE -- rows dropped at JOIN' END AS result;

-- 4. Measures are non-negative where expected.
SELECT
    'fact_sales_non_negative_measures' AS check_name,
    CASE WHEN MIN(line_total) >= 0 AND MIN(quantity) >= 0
         THEN 'PASS' ELSE 'WARN -- negative quantity or total' END AS result
FROM fact_sales;
