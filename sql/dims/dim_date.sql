-- ============================================================
-- DIM_DATE : date dimension from raw date data
-- ============================================================
-- Grain: one row per calendar date.
-- Natural key: date_key from the source calendar table.
-- Surrogate key: date_key is kept as the join key because facts already
-- reference the calendar date directly.
-- ============================================================

CREATE OR REPLACE TABLE dim_date AS
SELECT
    CAST(date_key AS DATE)       AS date_key,
    year,
    quarter,
    month,
    month_name,
    week_iso,
    day_of_week,
    day_name,
    CAST(is_weekend AS BOOLEAN)  AS is_weekend,
    CURRENT_DATE                 AS loaded_at
FROM raw_dim_date
WHERE date_key IS NOT NULL;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Every date key should be unique:
SELECT
    'dim_date_unique_date_keys' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT date_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_date;

-- 2. No null date keys:
SELECT
    'dim_date_no_null_date_keys' AS check_name,
    CASE WHEN COUNT(*) FILTER (WHERE date_key IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_date;
