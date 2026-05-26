-- ============================================================
-- DIM_ORDER_PROFILE : junk dimension for order-level flags
-- ============================================================
-- Grain: one row per distinct combination of order flags.
-- Source: raw_orders from S04 basket/flags data.
-- Surrogate key: order_profile_key generated for warehouse joins.
-- ============================================================

CREATE OR REPLACE TABLE dim_order_profile AS
WITH distinct_profiles AS (
    SELECT DISTINCT
        CAST(is_gift_wrapped AS INTEGER)       AS is_gift_wrapped,
        CAST(is_express_shipping AS INTEGER)   AS is_express_shipping,
        CAST(is_loyalty_redeemed AS INTEGER)   AS is_loyalty_redeemed,
        CAST(is_promo_applied AS INTEGER)      AS is_promo_applied,
        CAST(is_employee_purchase AS INTEGER)  AS is_employee_purchase,
        CAST(is_online_pickup AS INTEGER)      AS is_online_pickup,
        CAST(is_fragile AS INTEGER)            AS is_fragile,
        CAST(is_oversized AS INTEGER)          AS is_oversized
    FROM raw_orders
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY
            is_gift_wrapped,
            is_express_shipping,
            is_loyalty_redeemed,
            is_promo_applied,
            is_employee_purchase,
            is_online_pickup,
            is_fragile,
            is_oversized
    ) AS order_profile_key,
    is_gift_wrapped,
    is_express_shipping,
    is_loyalty_redeemed,
    is_promo_applied,
    is_employee_purchase,
    is_online_pickup,
    is_fragile,
    is_oversized,
    CASE
        WHEN is_gift_wrapped
           + is_express_shipping
           + is_loyalty_redeemed
           + is_promo_applied
           + is_employee_purchase
           + is_online_pickup
           + is_fragile
           + is_oversized = 0
        THEN 'standard_order'
        ELSE concat_ws(
            ' + ',
            CASE WHEN is_gift_wrapped = 1 THEN 'gift_wrapped' END,
            CASE WHEN is_express_shipping = 1 THEN 'express_shipping' END,
            CASE WHEN is_loyalty_redeemed = 1 THEN 'loyalty_redeemed' END,
            CASE WHEN is_promo_applied = 1 THEN 'promo_applied' END,
            CASE WHEN is_employee_purchase = 1 THEN 'employee_purchase' END,
            CASE WHEN is_online_pickup = 1 THEN 'online_pickup' END,
            CASE WHEN is_fragile = 1 THEN 'fragile' END,
            CASE WHEN is_oversized = 1 THEN 'oversized' END
        )
    END AS profile_name,
    CURRENT_DATE AS loaded_at
FROM distinct_profiles;

-- Backward-compatible alias for validation material that uses the
-- Kimball-style "junk_" prefix.
CREATE OR REPLACE VIEW junk_order_profile AS
SELECT * FROM dim_order_profile;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Every surrogate key should be unique.
SELECT
    'dim_order_profile_unique_surrogate_keys' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT order_profile_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_order_profile;

-- 2. The dimension should contain one row per observed flag combination.
SELECT
    'dim_order_profile_distinct_combinations' AS check_name,
    COUNT(*) AS dimension_rows,
    (
        SELECT COUNT(*)
        FROM (
            SELECT DISTINCT
                is_gift_wrapped,
                is_express_shipping,
                is_loyalty_redeemed,
                is_promo_applied,
                is_employee_purchase,
                is_online_pickup,
                is_fragile,
                is_oversized
            FROM raw_orders
        )
    ) AS source_combinations,
    CASE
        WHEN COUNT(*) = (
            SELECT COUNT(*)
            FROM (
                SELECT DISTINCT
                    is_gift_wrapped,
                    is_express_shipping,
                    is_loyalty_redeemed,
                    is_promo_applied,
                    is_employee_purchase,
                    is_online_pickup,
                    is_fragile,
                    is_oversized
                FROM raw_orders
            )
        )
        THEN 'PASS'
        ELSE 'FAIL'
    END AS result
FROM dim_order_profile;
