# S04 README -- Basket & Flags Reproducibility

Ce README explique comment reproduire les livrables de la seance S04 : junk dimension, analyse de panier, schema, board brief et brief executif.

## Objectif S04

Repondre a la question du CEO :

> Quels patterns de commande NexaMart sont importants pour les operations, et quels produits sont achetes ensemble ?

La seance S04 ajoute deux patterns au modele NexaMart :

- `order_number` comme dimension degeneree dans `fact_sales` ;
- `dim_order_profile` comme junk dimension pour regrouper les 8 flags operationnels de commande.

## Fichiers produits

| Fichier | Role |
|---|---|
| `sql/dims/dim_order_profile.sql` | Cree la junk dimension des profils de commande. |
| `sql/facts/fact_sales.sql` | Ajoute `order_profile_key` dans la table de faits. |
| `sql/analysis/basket_pairs.sql` | Produit l'analyse de panier et les validations S04. |
| `docs/schema-v2.md` | Documente le schema Mermaid apres S04. |
| `docs/board-briefs/s04-basket-flags.md` | Resume executif court pour VP / board. |
| `answers/S04_executive_brief.md` | Brief principal de la seance S04. |
| `docs/worked-examples/s04-basket-flags-walkthrough.md` | Procedure detaillee de travail et de verification. |

## Pre-requis

- Se placer a la racine du depot avant d'executer les commandes.
- Avoir `make` disponible dans l'environnement.
- Avoir DuckDB disponible pour executer les requetes contre `db/nexamart.duckdb`.
- Generer les donnees synthetiques si elles ne sont pas deja presentes :

```bash
make generate
```

- Fermer toute session DuckDB ou SQLTools qui garde `db/nexamart.duckdb` ouvert avant de lancer `make load`.
- Tous les chemins de ce README sont relatifs a la racine du depot. Aucun chemin absolu n'est requis pour reproduire S04 sur un clone propre.
- Verifier que `db/nexamart.duckdb` n'est pas versionne comme source de verite : il est regenere par `make load`.

## Comment reproduire

Depuis la racine du depot, sur un clone propre :

```bash
make generate
make load
```

Si les CSV sont deja presents et n'ont pas change, `make load` suffit :

```bash
make load
```

Cette commande recharge les CSV dans DuckDB et execute les scripts SQL dans l'ordre :

```text
sql/staging/
sql/dims/
sql/facts/
```

Les lignes importantes attendues dans la sortie sont :

```text
OK sql/dims/dim_order_profile.sql
OK sql/facts/fact_sales.sql
```

Ensuite, executer les requetes d'analyse :

```bash
duckdb db/nexamart.duckdb -cmd ".headers on" -cmd ".mode markdown" < sql/analysis/basket_pairs.sql
```

## Requetes principales

### Profils operationnels

```sql
SELECT
    op.profile_name AS profile_label,
    COUNT(DISTINCT f.order_number) AS n_orders,
    COUNT(*) AS order_lines,
    ROUND(SUM(f.line_total), 2) AS revenue,
    ROUND(AVG(f.line_total), 2) AS avg_line_total
FROM fact_sales f
JOIN dim_order_profile op
    ON op.order_profile_key = f.order_profile_key
GROUP BY op.profile_name
ORDER BY n_orders DESC, revenue DESC
LIMIT 20;
```

### Paires de produits

```sql
SELECT
    pa.product_id AS product_a_id,
    pa.product_name AS product_a_name,
    pa.category AS product_a_category,
    pb.product_id AS product_b_id,
    pb.product_name AS product_b_name,
    pb.category AS product_b_category,
    COUNT(DISTINCT f1.order_number) AS baskets_together,
    ROUND(SUM(f1.line_total + f2.line_total), 2) AS pair_line_revenue
FROM fact_sales f1
JOIN fact_sales f2
    ON f1.order_number = f2.order_number
   AND f1.product_key < f2.product_key
JOIN dim_product pa
    ON pa.product_key = f1.product_key
JOIN dim_product pb
    ON pb.product_key = f2.product_key
GROUP BY
    pa.product_id, pa.product_name, pa.category,
    pb.product_id, pb.product_name, pb.category
ORDER BY baskets_together DESC, pair_line_revenue DESC
LIMIT 20;
```

### Paires de categories

```sql
SELECT
    pa.category AS category_a,
    pb.category AS category_b,
    COUNT(DISTINCT f1.order_number) AS baskets_together,
    ROUND(SUM(f1.line_total + f2.line_total), 2) AS pair_line_revenue
FROM fact_sales f1
JOIN fact_sales f2
    ON f1.order_number = f2.order_number
   AND f1.product_key < f2.product_key
JOIN dim_product pa
    ON pa.product_key = f1.product_key
JOIN dim_product pb
    ON pb.product_key = f2.product_key
WHERE pa.category < pb.category
GROUP BY pa.category, pb.category
ORDER BY baskets_together DESC, pair_line_revenue DESC;
```

## Resultats attendus

| Controle / resultat | Valeur attendue |
|---|---:|
| Profils observes dans `dim_order_profile` | 97 |
| Lignes dans `fact_sales` | 2 147 |
| Commandes distinctes dans `fact_sales` | 667 |
| Profils utilises dans `fact_sales` | 95 |
| `order_profile_key` nulles | 0 |
| Cles `order_profile_key` orphelines | 0 |
| Doublons au grain `(order_number, sale_line_id)` | 0 |
| Self-pairs dans l'analyse panier | 0 |
| Flags `raw_orders` nuls | 0 |
| Flags `raw_orders` hors domaine `0/1` | 0 |

## Resultats business utilises

### Top profils operationnels

| Profil | Commandes | Revenu |
|---|---:|---:|
| `standard_order` | 118 | 87 055,52 $ |
| `loyalty_redeemed` | 66 | 45 600,89 $ |
| `express_shipping` | 45 | 30 741,56 $ |
| `gift_wrapped` | 39 | 29 028,91 $ |
| `fragile` | 36 | 28 874,76 $ |

### Top paires de categories

| Categorie A | Categorie B | Paniers ensemble | Revenu associe |
|---|---|---:|---:|
| Clothing | Sports & Outdoors | 78 | 24 498,95 $ |
| Clothing | Pet Supplies | 65 | 41 915,33 $ |
| Clothing | Grocery | 61 | 22 786,96 $ |
| Electronics | Sports & Outdoors | 60 | 15 276,54 $ |
| Electronics | Pet Supplies | 55 | 32 689,96 $ |


## Checks ajoutes apres feedback

Le feedback S04 demandait de documenter les cas limites. Le fichier `sql/analysis/basket_pairs.sql` inclut maintenant :

- un controle des flags nuls et hors domaine `0/1` dans `raw_orders` ;
- une distribution des profils pour reperer les profils dominants et rares ;
- un petit echantillon de commandes pour verifier manuellement que les flags sources pointent vers le bon `order_profile_key`.

Pour executer seulement les analyses S04 :

```bash
duckdb db/nexamart.duckdb -cmd ".headers on" -cmd ".mode markdown" < sql/analysis/basket_pairs.sql
```

## Validation finale

Executer :

```bash
make check
```

Selon l'avancement du cours, certains checks de tables futures peuvent echouer ou etre ignores. Pour S04, verifier au minimum :

- `dim_order_profile` existe ;
- `fact_sales` existe ;
- le grain `(order_number, sale_line_id)` reste unique ;
- `order_profile_key` est non nul dans `fact_sales` ;
- les resultats cites dans les briefs sont reproductibles avec `sql/analysis/basket_pairs.sql`.

## Notes

- Les donnees sont synthetiques ; les recommandations business doivent etre testees avant decision operationnelle.
- Les co-occurrences de panier indiquent une affinite observee, pas une causalite.
- `Pet Supplies` est une categorie prometteuse pour les recommandations croisees, car elle apparait dans plusieurs paires de categories a fort revenu.
