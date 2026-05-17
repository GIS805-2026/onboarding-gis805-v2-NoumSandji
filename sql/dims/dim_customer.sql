-- ============================================================
-- DIM_CUSTOMER : customer dimension from raw customer data
-- ============================================================
-- Grain: one row per customer.
-- Natural key: customer_id from the source system.
-- Surrogate key: customer_key generated for warehouse joins.
-- ============================================================

CREATE OR REPLACE TABLE dim_customer AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id) AS customer_key,
    customer_id,
    first_name || ' ' || last_name           AS full_name,
    first_name,
    last_name,
    email_domain,
    city,
    province,
    loyalty_segment,
    CAST(join_date AS DATE)                  AS join_date,
    CURRENT_DATE                             AS loaded_at
FROM raw_dim_customer
WHERE customer_id IS NOT NULL;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Every surrogate key should be unique:
SELECT
    'dim_customer_unique_surrogate_keys' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT customer_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_customer;

-- 2. No null natural keys:
SELECT
    'dim_customer_no_null_natural_keys' AS check_name,
    CASE WHEN COUNT(*) FILTER (WHERE customer_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_customer;
