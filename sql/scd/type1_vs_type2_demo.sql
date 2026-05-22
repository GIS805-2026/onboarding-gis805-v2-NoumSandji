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


