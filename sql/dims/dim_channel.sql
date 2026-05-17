-- ============================================================
-- DIM_CHANNEL : channel dimension from raw channel data
-- ============================================================
-- Grain: one row per sales channel.
-- Natural key: channel_id from the source system.
-- Surrogate key: channel_key generated for warehouse joins.
-- ============================================================

CREATE OR REPLACE TABLE dim_channel AS
SELECT
    ROW_NUMBER() OVER (ORDER BY channel_id) AS channel_key,
    channel_id,
    channel_name,
    channel_type,
    CURRENT_DATE                            AS loaded_at
FROM raw_dim_channel
WHERE channel_id IS NOT NULL;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- 1. Every surrogate key should be unique:
SELECT
    'dim_channel_unique_surrogate_keys' AS check_name,
    CASE WHEN COUNT(*) = COUNT(DISTINCT channel_key) THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_channel;

-- 2. No null natural keys:
SELECT
    'dim_channel_no_null_natural_keys' AS check_name,
    CASE WHEN COUNT(*) FILTER (WHERE channel_id IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_channel;
