# S03 Executive Brief — SCD Type 1 vs Type 2

## Question exécutive

Comment NexaMart peut-elle conserver une lecture fiable des ventes régionales
quand un magasin change de région après une fusion administrative ?

## Résumé de la recommandation

Je recommande d’utiliser un SCD Type 2 pour `dim_store.region`.

La raison business est que les ventes historiques doivent rester associées à
la région qui était vraie au moment de la transaction. Un simple Type 1
réécrit l’historique et peut conduire la direction à mal évaluer la performance
réelle des régions.

## Scénario analysé

Le magasin NexaMart-Gatineau était rattaché à la région `Outaouais`.
À partir du `2026-03-01`, il est rattaché à la région `Québec`.

Deux traitements ont été comparés :

- Type 1 : mise à jour directe de la région de `Outaouais` vers `Québec`.
- Type 2 : conservation de l’ancienne version `Outaouais` et création d’une
  nouvelle version `Québec`.

## Rapport de référence avant changement

 duckdb db/nexamart.duckdb -cmd ".headers on" -cmd ".mode markdown" < sql/scd/type1_vs_type2_demo.sql

|  region   | total_sales | total_margin | margin_pct |
|-----------|------------:|-------------:|-----------:|
| Québec    | 175590.71   | 83079.54     | 47.31      |
| Ontario   | 114114.23   | 52698.76     | 46.18      |
| Estrie    | 48098.03    | 24157.20     | 50.22      |
| Outaouais | 48096.60    | 24232.46     | 50.38      |
| Alberta   | 47326.76    | 21484.47     | 45.4       |
| BC        | 40956.63    | 20661.61     | 50.45      |

Observation :
Avant la simulation SCD, Québec est la région avec le plus grand volume de ventes, avec **175 590,71 $**. Outaouais est beaucoup plus petite, avec **48 096,60 $** de ventes, mais sa marge en pourcentage est plus élevée : **50,38 %** contre **47,31 %** pour Québec. Cela signifie qu’Outaouais vend moins, mais garde plus de marge pour chaque dollar vendu

## Résultat avec SCD Type 1

```sql
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
```

| region  | total_sales | total_margin | margin_pct |
|---------|------------:|-------------:|-----------:|
| Québec  | 223687.31   | 107312.00    | 47.97      |
| Ontario | 114114.23   | 52698.76     | 46.18      |
| Estrie  | 48098.03    | 24157.20     | 50.22      |
| Alberta | 47326.76    | 21484.47     | 45.4       |
| BC      | 40956.63    | 20661.61     | 50.45      |

Observation :

Après application du SCD type1, les ventes de la regions Outaouais sont réattribuées à celles du Québec, et on n'a plus de traçabilité de la region Outaouais. Le total global des ventes ne change pas, mais la lecture régionale
devient trompeuse.

