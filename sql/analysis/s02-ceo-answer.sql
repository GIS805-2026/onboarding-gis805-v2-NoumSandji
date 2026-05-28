-- S02 CEO answer
-- Question: quelles categories de produits declinent dans quelles regions, par trimestre ?
-- Grain de fact_sales: une ligne de commande, identifiee par (order_number, sale_line_id).

-- 1) Revenus par categorie, region et trimestre.
SELECT
    p.category,
    s.region,
    d.quarter,
    ROUND(SUM(f.line_total), 2) AS total_revenue,
    COUNT(*) AS nb_lignes
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
JOIN dim_store s
    ON f.store_key = s.store_key
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    p.category,
    s.region,
    d.quarter
ORDER BY
    total_revenue DESC
LIMIT 10;

-- 2) Detection des baisses: comparaison d'un trimestre avec le trimestre precedent.
WITH revenue_by_quarter AS (
    SELECT
        p.category,
        s.region,
        d.quarter,
        ROUND(SUM(f.line_total), 2) AS total_revenue
    FROM fact_sales f
    JOIN dim_product p
        ON f.product_key = p.product_key
    JOIN dim_store s
        ON f.store_key = s.store_key
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        p.category,
        s.region,
        d.quarter
),
with_previous AS (
    SELECT
        category,
        region,
        quarter,
        total_revenue,
        LAG(total_revenue) OVER (
            PARTITION BY category, region
            ORDER BY quarter
        ) AS previous_revenue
    FROM revenue_by_quarter
)
SELECT
    category,
    region,
    quarter,
    previous_revenue,
    total_revenue,
    ROUND(total_revenue - previous_revenue, 2) AS revenue_change
FROM with_previous
WHERE previous_revenue IS NOT NULL
ORDER BY
    revenue_change ASC
LIMIT 10;

-- 3) Controle des colonnes de groupement utilisees dans la reponse CEO.
SELECT
    SUM(CASE WHEN p.category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN s.region IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN d.quarter IS NULL THEN 1 ELSE 0 END) AS null_quarter
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
JOIN dim_store s
    ON f.store_key = s.store_key
JOIN dim_date d
    ON f.date_key = d.date_key;
