# Board Brief — S01

## Question du CEO
Quelles catégories de produits déclinent,dans quelles régions, et pourquoi?

## Réponse exécutive
Les catégories **Pet Supplies, Toys & Games, Beauty & Health** performent dans presque toutes les régions mais avec une forte concentration dans les region du **Québec et Ontario**.

on observe également que les catégories **Electronics, Clothings, Home & Garden** sous-performent dans les regions **BC, Estie, Alberta et Outaouais**.

possiblement lié aux remises efféctuées, à la saisonnalité ou à d'autres facteurs à explorer.


## Décisions de modélisation
- **Grain** : une ligne dans la table raw_fact_sales représente une vente d'un produit dans un magasin,à travers une chaîne de vente à une date donnée.

- **mesures ciblées** : le revenu, la quantié, le panier moyen, le volume de transactions

- **Dimensions ciblées** : produit(pour avoir la catégorie de produit), magasin(store, pour avoir  la region), et la periode

- **fait principal** : raw_fact_sales en tant que fait transactionnel à agréger par catégorie/region/periode(mois,trimestre,semestre,année)

## Preuve
- **Identification des tables :**
```text
SHOW TABLES;
┌────────────────────────────────┐
│              name              │
│            varchar             │
├────────────────────────────────┤
│ raw_bridge_campaign_allocation │
│ raw_bridge_customer_segment    │
│ raw_customer_changes           │
│ raw_customer_profile_bands     │
│ raw_customer_scd3_history      │
│ raw_dim_channel                │
│ raw_dim_customer               │
│ raw_dim_date                   │
│ raw_dim_geography              │
│ raw_dim_product                │
│ raw_dim_segment_outrigger      │
│ raw_dim_store                  │
│ raw_fact_budget                │
│ raw_fact_daily_inventory       │
│ raw_fact_inventory_snapshot    │
│ raw_fact_order_pipeline        │
│ raw_fact_orders_transaction    │
│ raw_fact_promo_exposure        │
│ raw_fact_returns               │
│ raw_fact_sales                 │
│ raw_fact_shipment              │
│ raw_order_lines                │
│ raw_orders                     │
│ raw_store_changes              │
├────────────────────────────────┤
│            24 rows             │
└────────────────────────────────┘
```

- **Vérification des lignes dans les tables**:
```text
SELECT COUNT(*) FROM raw_dim_customer;
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│          159 │
└──────────────┘

SELECT COUNT(*) FROM raw_dim_product;
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│           50 │
└──────────────┘
SELECT COUNT(*) FROM raw_dim_store;
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│           10 │
└──────────────┘

SELECT COUNT(*) FROM raw_fact_sales;
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│         2147 │
└──────────────┘
```

- **à quoi ressemble nos données:**
```text
 SELECT * FROM raw_fact_sales LIMIT 5;
┌──────────────┬──────────────┬────────────┬─────────────┬───┬──────────────┬───────────┬────────────┐
│ sale_line_id │ order_number │ order_date │ customer_id │ … │ discount_pct │ net_price │ line_total │
│    int64     │   varchar    │    date    │   varchar   │   │    double    │  double   │   double   │
├──────────────┼──────────────┼────────────┼─────────────┼───┼──────────────┼───────────┼────────────┤
│            1 │ ORD-000001   │ 2025-07-30 │ CUS-00046   │ … │          0.1 │    124.22 │     248.44 │
│            2 │ ORD-000001   │ 2025-07-30 │ CUS-00046   │ … │          0.0 │     35.95 │     107.85 │
│            3 │ ORD-000001   │ 2025-07-30 │ CUS-00046   │ … │          0.0 │    163.97 │     491.91 │
│            4 │ ORD-000002   │ 2025-09-14 │ CUS-00045   │ … │         0.05 │    108.11 │     108.11 │
│            5 │ ORD-000002   │ 2025-09-14 │ CUS-00045   │ … │          0.1 │     13.67 │      41.01 │
├──────────────┴──────────────┴────────────┴─────────────┴───┴──────────────┴───────────┴────────────┤
│ 5 rows                                                                        12 columns (7 shown) │
└────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

- **Sur quelles périodes s'étendent nos données :**

```text
SELECT
    MIN(order_date) AS first_sale,
    MAX(order_date) AS last_sale,
    COUNT(DISTINCT order_date) AS n_distinct_days
FROM raw_fact_sales;

┌────────────┬────────────┬─────────────────┐
│ first_sale │ last_sale  │ n_distinct_days │
│    date    │    date    │      int64      │
├────────────┼────────────┼─────────────────┤
│ 2025-01-01 │ 2025-12-31 │             310 │
└────────────┴────────────┴─────────────────┘
```

- **raw_dim_product**: contient des catégories valides et aucune catégorie NULL.
```text
SELECT DISTINCT category FROM raw_dim_product;
┌───────────────────┐
│     category      │
│      varchar      │
├───────────────────┤
│ Clothing          │
│ Grocery           │
│ Books & Media     │
│ Home & Garden     │
│ Sports & Outdoors │
│ Electronics       │
│ Pet Supplies      │
│ Automotive        │
│ Toys & Games      │
│ Beauty & Health   │
├───────────────────┤
│      10 rows      │
└───────────────────┘
```
- **Raw_dim_store**: contient des régions valides et aucune region Null
```text
SELECT DISTINCT region FROM raw_dim_store order by region;
┌───────────┐
│  region   │
│  varchar  │
├───────────┤
│ Alberta   │
│ BC        │
│ Estrie    │
│ Ontario   │
│ Outaouais │
│ Québec    │
└───────────┘
```
- **raw_dim_date**: date a le même format de date que dans la table de vente raw_fact_sales
```text
select * from raw_dim_date LIMIT 20;
┌────────────┬───────┬─────────┬───────┬────────────┬──────────┬─────────────┬───────────┬────────────┐
│  date_key  │ year  │ quarter │ month │ month_name │ week_iso │ day_of_week │ day_name  │ is_weekend │
│    date    │ int64 │  int64  │ int64 │  varchar   │  int64   │    int64    │  varchar  │   int64    │
├────────────┼───────┼─────────┼───────┼────────────┼──────────┼─────────────┼───────────┼────────────┤
│ 2024-01-01 │  2024 │       1 │     1 │ January    │        1 │           1 │ Monday    │          0 │
│ 2024-01-02 │  2024 │       1 │     1 │ January    │        1 │           2 │ Tuesday   │          0 │
│ 2024-01-03 │  2024 │       1 │     1 │ January    │        1 │           3 │ Wednesday │          0 │
│ 2024-01-04 │  2024 │       1 │     1 │ January    │        1 │           4 │ Thursday  │          0 │
│ 2024-01-05 │  2024 │       1 │     1 │ January    │        1 │           5 │ Friday    │          0 │
│ 2024-01-06 │  2024 │       1 │     1 │ January    │        1 │           6 │ Saturday  │          1 │
│ 2024-01-07 │  2024 │       1 │     1 │ January    │        1 │           7 │ Sunday    │          1 │
│ 2024-01-08 │  2024 │       1 │     1 │ January    │        2 │           1 │ Monday    │          0 │
│ 2024-01-09 │  2024 │       1 │     1 │ January    │        2 │           2 │ Tuesday   │          0 │
│ 2024-01-10 │  2024 │       1 │     1 │ January    │        2 │           3 │ Wednesday │          0 │
│ 2024-01-11 │  2024 │       1 │     1 │ January    │        2 │           4 │ Thursday  │          0 │
│ 2024-01-12 │  2024 │       1 │     1 │ January    │        2 │           5 │ Friday    │          0 │
│ 2024-01-13 │  2024 │       1 │     1 │ January    │        2 │           6 │ Saturday  │          1 │
│ 2024-01-14 │  2024 │       1 │     1 │ January    │        2 │           7 │ Sunday    │          1 │
│ 2024-01-15 │  2024 │       1 │     1 │ January    │        3 │           1 │ Monday    │          0 │
│ 2024-01-16 │  2024 │       1 │     1 │ January    │        3 │           2 │ Tuesday   │          0 │
│ 2024-01-17 │  2024 │       1 │     1 │ January    │        3 │           3 │ Wednesday │          0 │
│ 2024-01-18 │  2024 │       1 │     1 │ January    │        3 │           4 │ Thursday  │          0 │
│ 2024-01-19 │  2024 │       1 │     1 │ January    │        3 │           5 │ Friday    │          0 │
│ 2024-01-20 │  2024 │       1 │     1 │ January    │        3 │           6 │ Saturday  │          1 │
├────────────┴───────┴─────────┴───────┴────────────┴──────────┴─────────────┴───────────┴────────────┤
│ 20 rows                                                                                   9 columns │
└─────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
- Intégrité référentielle vérifiée: aucune ligne de raw_fact_sales n'a pas de product_id ou store_id absent des dimensions

```text
SELECT COUNT(*) FROM raw_fact_sales WHERE store_id NOT IN (SELECT store_id FROM raw_dim_store);
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│            0 │
└──────────────┘
```

```text
SELECT COUNT(*) FROM raw_fact_sales WHERE product_id NOT IN (SELECT product_id FROM raw_dim_product);
┌──────────────┐
│ count_star() │
│    int64     │
├──────────────┤
│            0 │
└──────────────┘
```

- première tendance des produits qui sous-performent
```text
SELECT
  p.category,
  s.region,
  AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
JOIN raw_dim_product p ON p.product_id = f.product_id
JOIN raw_dim_store s ON s.store_id = f.store_id
JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category, s.region
ORDER BY revenue ASC
LIMIT 20;

┌───────────────────┬───────────┬──────────────────────┬────────────────────┬─────────┬────────────────────┐
│     category      │  region   │     avg_discount     │      revenue       │ n_lines │     avg_ticket     │
│      varchar      │  varchar  │        double        │       double       │  int64  │       double       │
├───────────────────┼───────────┼──────────────────────┼────────────────────┼─────────┼────────────────────┤
│ Electronics       │ BC        │  0.05681818181818183 │             804.94 │      22 │  36.58818181818182 │
│ Electronics       │ Outaouais │                 0.05 │  834.3100000000002 │      17 │  49.07705882352942 │
│ Electronics       │ Estrie    │  0.05454545454545454 │            1071.85 │      22 │ 48.720454545454544 │
│ Home & Garden     │ BC        │  0.10555555555555557 │ 1156.3000000000002 │       9 │  128.4777777777778 │
│ Electronics       │ Alberta   │  0.02608695652173913 │ 1157.4200000000003 │      23 │ 50.322608695652185 │
│ Home & Garden     │ Outaouais │  0.07500000000000001 │            1355.25 │      10 │            135.525 │
│ Home & Garden     │ Alberta   │ 0.041666666666666664 │            1551.51 │      12 │           129.2925 │
│ Clothing          │ Outaouais │ 0.041999999999999996 │ 1800.3799999999999 │      25 │            72.0152 │
│ Home & Garden     │ Estrie    │             0.059375 │            2068.41 │      16 │         129.275625 │
│ Electronics       │ Ontario   │ 0.045555555555555564 │            2332.92 │      45 │ 51.842666666666666 │
│ Clothing          │ BC        │  0.07115384615384615 │  2350.920000000001 │      26 │  90.42000000000004 │
│ Clothing          │ Estrie    │  0.04531250000000001 │            2666.39 │      32 │         83.3246875 │
│ Grocery           │ Estrie    │             0.040625 │            3124.85 │      16 │         195.303125 │
│ Clothing          │ Alberta   │  0.05897435897435898 │ 3304.4099999999994 │      39 │  84.72846153846152 │
│ Sports & Outdoors │ Outaouais │  0.04318181818181819 │ 3323.1799999999994 │      22 │ 151.05363636363634 │
│ Electronics       │ Québec    │  0.05802469135802467 │  3459.540000000002 │      81 │  42.71037037037039 │
│ Toys & Games      │ BC        │ 0.025000000000000005 │ 3767.2000000000003 │      12 │ 313.93333333333334 │
│ Sports & Outdoors │ BC        │                0.034 │            3923.03 │      25 │           156.9212 │
│ Beauty & Health   │ Outaouais │                 0.03 │            4392.11 │      20 │ 219.60549999999998 │
│ Grocery           │ Alberta   │  0.07608695652173912 │            4491.41 │      23 │  195.2786956521739 │
├───────────────────┴───────────┴──────────────────────┴────────────────────┴─────────┴────────────────────┤
│ 20 rows                                                                                        6 columns │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

- catégories de produit qui performent
```text
SELECT
  p.category,
  s.region,
  AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
  AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
JOIN raw_dim_product p ON p.product_id = f.product_id
JOIN raw_dim_store s ON s.store_id = f.store_id
JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category, s.region
ORDER BY revenue DESC
LIMIT 20;

┌───────────────────┬───────────┬──────────────────────┬────────────────────┬─────────┬────────────────────┐
│     category      │  region   │     avg_discount     │      revenue       │ n_lines │     avg_ticket     │
│      varchar      │  varchar  │        double        │       double       │  int64  │       double       │
├───────────────────┼───────────┼──────────────────────┼────────────────────┼─────────┼────────────────────┤
│ Pet Supplies      │ Québec    │  0.05705882352941176 │ 34259.659999999996 │      85 │  403.0548235294117 │
│ Toys & Games      │ Québec    │  0.05000000000000001 │           24123.91 │      80 │         301.548875 │
│ Books & Media     │ Québec    │  0.06776315789473686 │ 23455.449999999997 │      76 │  308.6243421052631 │
│ Beauty & Health   │ Québec    │  0.04999999999999999 │ 22123.309999999987 │      90 │ 245.81455555555542 │
│ Pet Supplies      │ Ontario   │  0.05384615384615385 │ 22065.299999999996 │      52 │ 424.33269230769224 │
│ Automotive        │ Québec    │  0.06346153846153847 │            18705.7 │      52 │            359.725 │
│ Sports & Outdoors │ Québec    │ 0.052499999999999984 │           17439.33 │     100 │           174.3933 │
│ Beauty & Health   │ Ontario   │ 0.041044776119402986 │ 16426.799999999996 │      67 │ 245.17611940298502 │
│ Grocery           │ Québec    │ 0.050632911392405056 │ 16394.310000000005 │      79 │ 207.52291139240512 │
│ Toys & Games      │ Ontario   │  0.04387755102040816 │ 14827.989999999998 │      49 │  302.6120408163265 │
│ Automotive        │ Ontario   │  0.04736842105263159 │ 13447.160000000002 │      38 │  353.8726315789474 │
│ Books & Media     │ Ontario   │  0.04615384615384616 │ 12192.279999999999 │      39 │ 312.62256410256407 │
│ Sports & Outdoors │ Ontario   │ 0.057499999999999996 │ 11097.609999999997 │      60 │ 184.96016666666662 │
│ Grocery           │ Ontario   │  0.05399999999999998 │ 10728.800000000001 │      50 │ 214.57600000000002 │
│ Pet Supplies      │ Estrie    │ 0.060416666666666674 │            10465.0 │      24 │  436.0416666666667 │
│ Pet Supplies      │ Outaouais │                0.062 │            9728.45 │      25 │ 389.13800000000003 │
│ Clothing          │ Québec    │  0.04137931034482758 │  9601.599999999995 │     116 │  82.77241379310341 │
│ Toys & Games      │ Outaouais │  0.04444444444444445 │  8500.539999999999 │      27 │ 314.83481481481476 │
│ Pet Supplies      │ Alberta   │  0.05833333333333332 │  7818.130000000001 │      18 │  434.3405555555556 │
│ Automotive        │ Outaouais │                 0.02 │  7739.919999999999 │      20 │            386.996 │
├───────────────────┴───────────┴──────────────────────┴────────────────────┴─────────┴────────────────────┤
│ 20 rows                                                                                        6 columns │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```
## Validation
- les commandes make generate, make load, make check ont été exécutées
- les requêtes de validation ont été effectuées


## Risques / limites

- les données brutes seules ne montrent pas encore les causes de sous-performance.
- La question exécutive requiert des données de causalité que les tables transactionnelles ne garantissent pas forcement.

## Prochaine recommandation
- construire une table de fait fact_sales avec les dimensions conformes spécifiques
-Ajouter des dimensions de cause: promotions,retours,campagnes marketing, disponibilité de stock
