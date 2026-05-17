# Board Brief — S01

## Question du CEO
Quelles catégories de produits déclinent,dans quelles régions, et pourquoi?

## Décisions de modélisation
- **Grain** : une ligne dans la table raw_fact_sales représente une vente d'un produit dans un magasin,à travers une chaîne de vente à une date donnée.

- **mesures ciblées** : le revenu, la quantié, le panier moyen, le volume de transactions

- **Dimensions ciblées** : produit(pour avoir la catégorie de produit), magasin(store, pour avoir  la region), et la periode

- **fait principal** : raw_fact_sales en tant que fait transactionnel à agréger par catégorie/region/periode(mois,trimestre,semestre,année)

## Preuve
- Intégrité référentielle vérifiée: aucune ligne de raw_fact_sales n'a pas de product_id ou store_id absent des dimensions

```sql
SELECT COUNT(*) FROM raw_fact_sales WHERE store_id NOT IN (SELECT store_id FROM raw_dim_store);
```
| count_star() |
|-------------:|
| 0            |

```sql
SELECT COUNT(*) FROM raw_fact_sales WHERE product_id NOT IN (SELECT product_id FROM raw_dim_product);
```
| count_star() |
|-------------:|
| 0            |

## Preuve SQL question CEO

```sql
SELECT
  p.category,
  s.region,
  d.quarter,
 -- AVG(f.discount_pct) AS avg_discount,
  SUM(f.line_total) AS revenue,
  COUNT(*) AS n_lines,
 -- AVG(f.line_total) AS avg_ticket
FROM raw_fact_sales f
JOIN raw_dim_product p ON p.product_id = f.product_id
JOIN raw_dim_store s ON s.store_id = f.store_id
JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category, s.region,d.quarter
ORDER BY revenue ASC, d.quarter ASC
LIMIT 10;

```
|   category    |  region   | quarter |      revenue       | n_lines |
|---------------|-----------|--------:|-------------------:|--------:|
| Electronics   | BC        | 1       | 34.26              | 2       |
| Home & Garden | Alberta   | 2       | 41.22              | 1       |
| Electronics   | Alberta   | 2       | 81.52              | 2       |
| Electronics   | BC        | 2       | 112.35             | 2       |
| Electronics   | Outaouais | 1       | 116.89999999999999 | 2       |
| Electronics   | Outaouais | 4       | 121.53             | 2       |
| Home & Garden | Alberta   | 1       | 123.8              | 1       |
| Home & Garden | Outaouais | 1       | 123.8              | 1       |
| Home & Garden | BC        | 1       | 152.83             | 2       |
| Electronics   | Alberta   | 3       | 169.95999999999998 | 3       |

## Réponse exécutive
Les catégories **Pet Supplies, Toys & Games, Beauty & Health** performent dans presque toutes les régions mais avec une forte concentration dans les regions du **Québec et Ontario**.

on observe également que les catégories **Electronics, Clothings, Home & Garden** sous-performent dans les regions **BC, Estie, Alberta et Outaouais**.

possiblement lié aux remises efféctuées, à la saisonnalité ou à d'autres facteurs à explorer.

## Validation
- les commandes make generate, make load, make check ont été exécutées
- les requêtes de validation ont été effectuées


## Risques / limites

- les données brutes seules ne montrent pas encore les causes de sous-performance.
- La question exécutive requiert des données de causalité que les tables transactionnelles ne garantissent pas forcement.

## Prochaine recommandation
- construire une table de fait fact_sales avec les dimensions conformes spécifiques
-Ajouter des dimensions de cause: promotions,retours,campagnes marketing, disponibilité de stock