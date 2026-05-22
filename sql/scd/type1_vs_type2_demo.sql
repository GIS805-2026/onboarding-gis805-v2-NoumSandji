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

UPDATE dim_store
SET region = 'Québec'
WHERE region = 'Outaouais'
  AND is_current = TRUE;

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

