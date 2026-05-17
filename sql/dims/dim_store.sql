-- ============================================================
-- DIM_STORE : store dimension from raw store data
-- ============================================================
-- Grain: one row per store.
-- Natural key: store_id from the source system.
-- Surrogate key: store_key generated for warehouse joins.
-- ============================================================

CREATE OR REPLACE TABLE dim_store AS
SELECT
    ROW_NUMBER() OVER (ORDER BY store_id) AS store_key,
    store_id,
    store_name,
    city,
    region,
    province,
    store_type,
    CURRENT_DATE                          AS loaded_at
FROM raw_dim_store
WHERE store_id IS NOT NULL;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Every surrogate key should be unique:
SELECT
    'dim_store_unique_surrogate_keys' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT store_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_store;

-- 2. No null natural keys:
SELECT
    'dim_store_no_null_natural_keys' AS check_name,
    CASE WHEN COUNT(*) FILTER (WHERE store_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_store;
