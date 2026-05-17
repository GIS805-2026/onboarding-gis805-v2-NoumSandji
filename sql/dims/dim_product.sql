-- ============================================================
-- DIM_PRODUCT : product dimension from raw product data
-- ============================================================
-- Grain: one row per product.
-- Natural key: product_id from the source system.
-- Surrogate key: product_key generated for warehouse joins.
-- ============================================================

CREATE OR REPLACE TABLE dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_id) AS product_key,
    product_id,
    product_name,
    category,
    subcategory,
    brand,
    CAST(unit_cost AS DECIMAL(12, 2))       AS unit_cost,
    CAST(unit_price AS DECIMAL(12, 2))      AS unit_price,
    CURRENT_DATE                            AS loaded_at
FROM raw_dim_product
WHERE product_id IS NOT NULL;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Every surrogate key should be unique:
SELECT
    'dim_product_unique_surrogate_keys' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT product_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_product;

-- 2. No null natural keys:
SELECT
    'dim_product_no_null_natural_keys' AS check_name,
    CASE WHEN COUNT(*) FILTER (WHERE product_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_product;
