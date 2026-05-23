# S03 Executive Brief — SCD Type 1 vs Type 2

## Question du CEO

Quels changements dans nos dimensions doivent garder la vérité historique,
et lesquels peuvent être écrasés ?

## Réponse exécutive

Les changements qui influencent les rapports de performance doivent garder
leur historique. Pour NexaMart, la `region` d'un magasin doit être historisée,
car les ventes doivent rester associées à la région vraie au moment de la
transaction. Les corrections simples, comme une faute dans un nom de magasin
ou une adresse courriel, peuvent être écrasées sans risque analytique majeur.

## Décisions de modélisation

- **Grain :** une ligne de `fact_sales` représente une ligne de commande, identifiée par `(order_number, sale_line_id)`.
- **Mesures utilisées :** `line_total` pour les ventes, `margin_amount` pour la marge brute, et `margin_pct` calculée comme `SUM(margin_amount) / SUM(line_total)`.
- **Dimension principale :** `dim_store`, car le scénario S03 porte sur le changement de région du magasin Gatineau.
- **SCD Type 1 :** utilisé pour les corrections sans valeur historique, comme `store_name`.
- **SCD Type 2 :** recommandé pour `dim_store.region`, car une fusion régionale ne doit pas réécrire les ventes passées.
- **Hypothèse :** le magasin Gatineau passe de `Outaouais` à `Québec` à partir du `2026-03-01`.

## Preuve SQL

**Rapport de référence avant changement**

```sql
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

 **commande exécutée**:duckdb db/nexamart.duckdb -cmd ".headers on" -cmd ".mode markdown" < sql/scd/type1_vs_type2_demo.sql

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

**Résultat avec SCD Type 1**

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

**Résultat avec SCD Type 2**:
-**Vérifier les versions du magasin**
```sql
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
```
| BC        | 40956.63    | 20661.61     | 50.45      |
| store_key | store_id |      store_name       |  region   | effective_date |  end_date  | is_current |
|----------:|----------|-----------------------|-----------|----------------|------------|-----------:|
| 1         | STR-001  | NexaMart Centre-Ville | Québec    | 2025-01-01     |            | true       |
| 2         | STR-002  | NexaMart Rive-Sud     | Québec    | 2025-01-01     |            | true       |
| 3         | STR-003  | NexaMart Laval        | Québec    | 2025-01-01     |            | true       |
| 4         | STR-004  | NexaMart Gatineau     | Outaouais | 2025-01-01     | 2026-02-28 | false      |
| 11        | STR-004  | NexaMart Gatineau     | Québec    | 2026-03-01     |            | true       |

```sql
ALTER TABLE dim_store
ADD COLUMN effective_date DATE DEFAULT '2025-01-01';

ALTER TABLE dim_store
ADD COLUMN end_date DATE;

ALTER TABLE dim_store
ADD COLUMN is_current BOOLEAN DEFAULT TRUE;

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
```


|  region   | total_sales | total_margin |     margin_pct     |
|-----------|------------:|-------------:|-------------------:|
| Québec    | 175590.71   | 83079.54     | 0.4731431406593207 |
| Ontario   | 114114.23   | 52698.76     | 0.4618070857595937 |
| Estrie    | 48098.03    | 24157.20     | 0.5022492605206492 |
| Outaouais | 48096.60    | 24232.46     | 0.5038289608828899 |
| Alberta   | 47326.76    | 21484.47     | 0.4539602964580715 |
| BC        | 40956.63    | 20661.61     | 0.5044753437965966 |

Observation :

Avec le Type 2, les ventes historiques restent associées à Outaouais parce que
`fact_sales` conserve la clé substitut de l’ancienne version du magasin. La
nouvelle version Québec existe pour représenter le magasin à partir du
`2026-03-01`.

## KPI de risque

Le Type 1 aurait réattribué environ `48 096$` de ventes et `24 232 $` de marge de
la région Outaouais vers Québec.

Cela représente `50.38 %` des ventes régionales analysées.

## Risques /limites

Avec le Type 2, le CEO peut comparer correctement la performance d’Outaouais
avant la fusion avec celle de Québec après la fusion. Cette distinction évite
de conclure à tort que Québec performait mieux historiquement, alors qu’une
partie du revenu venait d’une région différente.

## Politique SCD recommandée

| Dimension | Attribut | Type SCD | Justification business |
|---|---|---:|---|
| dim_store | region | Type 2 | Les ventes doivent refléter la région du magasin au moment de la transaction. |
| dim_store | store_name | Type 1 | Une correction de nom ne change pas l’analyse historique. |
| dim_customer | loyalty_segment | Type 2 | Le marketing doit analyser les migrations entre segments dans le temps. |
| dim_customer | email | Type 1 | L’email est un attribut opérationnel, pas un axe stratégique d’analyse historique. |

## Prochaine recommandation
Approuver une politique SCD différenciée : historiser en Type 2 les changements qui modifient l’interprétation des ventes, comme la `région d’un magasin` ou le `segment d’un client` , et écraser en Type 1 les corrections sans valeur historique. Cette décision protège les rapports de performance régionale et évite de réattribuer rétroactivement des ventes à la mauvaise région.
