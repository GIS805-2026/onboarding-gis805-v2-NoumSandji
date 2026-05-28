-- ============================================================
-- S03 - Type 1 vs Type 2 demo
-- Objectif : montrer comment un changement de région peut
-- réécrire l'historique si on utilise SCD Type 1.
-- Scénario : le magasin Gatineau passe de Outaouais à Québec
-- le 2026-03-01.
-- ============================================================

-- ------------------------------------------------------------
-- 0. Rapport de référence AVANT changement
-- ------------------------------------------------------------
-- Ce rapport montre les ventes et la marge par région avant toute
-- simulation SCD.

SELECT
    s.region,
    SUM(f.line_total) AS total_sales,
    SUM(f.margin_amount) AS total_margin,
    ROUND(
        100 * SUM(f.margin_amount) / NULLIF(SUM(f.line_total), 0),
        2
    ) AS margin_pct
FROM fact_sales f
JOIN dim_store s
    ON f.store_key = s.store_key
GROUP BY s.region
ORDER BY total_sales DESC;

-- ------------------------------------------------------------
-- 1. Préparer dim_store pour les colonnes SCD
-- ------------------------------------------------------------

ALTER TABLE dim_store
ADD COLUMN effective_date DATE DEFAULT '2025-01-01';

ALTER TABLE dim_store
ADD COLUMN end_date DATE;

ALTER TABLE dim_store
ADD COLUMN is_current BOOLEAN DEFAULT TRUE;

-- ------------------------------------------------------------
-- 2. Simulation SCD Type 1 (trompeur): écraser la région
-- ------------------------------------------------------------
-- Type 1 = UPDATE direct. L'ancienne région disparaît.
-- C'est trompeur pour les rapports historiques.

/*UPDATE dim_store
SET region = 'Québec'
WHERE region = 'Outaouais'
  AND is_current = TRUE;*/

-- Rapport APRÈS Type 1
-- Attendu : Outaouais disparaît, ses ventes sont absorbées par Québec.

SELECT
    s.region,
    SUM(f.line_total) AS total_sales,
    SUM(f.margin_amount) AS total_margin,
    ROUND(
        100 * SUM(f.margin_amount) / NULLIF(SUM(f.line_total), 0),
        2
    ) AS margin_pct
FROM fact_sales f
JOIN dim_store s
    ON f.store_key = s.store_key
GROUP BY s.region
ORDER BY total_sales DESC;

-- IMPORTANT
-- ------------------------------------------------------------
-- Après ce bloc, réinitialiser la base avant de tester Type 2 :
--
-- make reset && make load
--
-- Puis relancer les ALTER TABLE du bloc 1 avant de continuer.
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 3. Simulation SCD Type 2 : historiser la région
-- ------------------------------------------------------------
-- Type 2 = on ferme l'ancienne version et on insère une nouvelle.
-- Les ventes passées restent liées à l'ancienne store_key.

-- 3.1 Insérer la nouvelle version Québec
INSERT INTO dim_store (
    store_key,
    store_id,
    store_name,
    region,
    effective_date,
    end_date,
    is_current
)
SELECT
    (SELECT MAX(store_key) FROM dim_store)
        + ROW_NUMBER() OVER (ORDER BY store_id) AS new_store_key,
    store_id,
    store_name,
    'Québec' AS region,
    DATE '2026-03-01' AS effective_date,
    NULL AS end_date,
    TRUE AS is_current
FROM dim_store
WHERE region = 'Outaouais'
  AND is_current = TRUE;

-- 3.2 Fermer l'ancienne version Outaouais
UPDATE dim_store
SET end_date = DATE '2026-02-28',
    is_current = FALSE
WHERE region = 'Outaouais'
  AND end_date IS NULL;

-- 3.3 Vérifier les versions du magasin
SELECT
    store_key,
    store_id,
    store_name,
    region,
    effective_date,
    end_date,
    is_current
FROM dim_store
WHERE store_name ILIKE '%Gatineau%'
   OR region IN ('Outaouais', 'Québec')
ORDER BY store_id, effective_date;

-- Rapport APRÈS Type 2
-- Attendu : Outaouais reste visible pour les ventes historiques,
-- car fact_sales pointe encore vers l'ancienne store_key.

SELECT
    s.region,
    SUM(f.line_total) AS total_sales,
    SUM(f.margin_amount) AS total_margin,
     ROUND(
        100 * SUM(f.margin_amount) / NULLIF(SUM(f.line_total), 0),
        2
    ) AS margin_pct
FROM fact_sales f
JOIN dim_store s
    ON f.store_key = s.store_key
GROUP BY s.region
ORDER BY total_sales DESC;

-- ------------------------------------------------------------
-- 4. Conclusion business
-- ------------------------------------------------------------
-- Type 1 : rapport trompeur, car il réattribue rétroactivement
-- les ventes Outaouais à Québec.
--
-- Type 2 : rapport correct, car les ventes historiques gardent
-- la région vraie au moment de la transaction.
-- ------------------------------------------------------------



-- ------------------------------------------------------------
-- 5. Validations SCD Type 2 et qualite du rapport
-- ------------------------------------------------------------
-- Ces controles documentent les cas limites mentionnes dans le feedback S03.

-- 5.1 Aucune vente ne doit etre regroupee dans une region NULL.
SELECT
    'null_region_in_sales_report' AS check_name,
    COUNT(*) AS null_region_rows,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales f
JOIN dim_store s
    ON f.store_key = s.store_key
WHERE s.region IS NULL;

-- 5.2 Une seule version courante doit exister par magasin naturel.
SELECT
    'one_current_store_version' AS check_name,
    COUNT(*) AS stores_with_multiple_current_versions,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM (
    SELECT store_id
    FROM dim_store
    WHERE is_current = TRUE
    GROUP BY store_id
    HAVING COUNT(*) > 1
);

-- 5.3 Les dates de validite ne doivent pas etre incoherentes.
SELECT
    'valid_scd_date_ranges' AS check_name,
    COUNT(*) AS invalid_ranges,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_store
WHERE end_date IS NOT NULL
  AND end_date < effective_date;

-- 5.4 Le magasin Gatineau doit avoir deux versions apres Type 2.
SELECT
    'gatineau_two_versions' AS check_name,
    COUNT(*) AS gatineau_versions,
    CASE WHEN COUNT(*) = 2 THEN 'PASS' ELSE 'FAIL' END AS result
FROM dim_store
WHERE store_id = 'STR-004';

-- 5.5 Les faits doivent toujours pointer vers une store_key existante.
SELECT
    'orphan_fact_store_key' AS check_name,
    COUNT(*) AS orphan_store_keys,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales f
LEFT JOIN dim_store s
    ON f.store_key = s.store_key
WHERE s.store_key IS NULL;
