# S04 Executive Brief -- Panier d'achat et drapeaux

## Question du CEO

Quels patterns de commande NexaMart sont importants pour les operations, et quels produits sont achetes ensemble ?

## Réponse exécutive

Les commandes `standard_order` restent le profil dominant de NexaMart, mais plusieurs profils operationnels meritent un suivi specifique : `loyalty_redeemed`, `express_shipping`, `gift_wrapped` et `fragile`. La nouvelle dimension junk `dim_order_profile` transforme les 8 drapeaux techniques de commande en profils nommes et exploitables par les operations.

L'analyse de panier montre aussi que les opportunités de ventes croisées ne sont pas seulement dans les produits similaires. Les associations les plus utiles traversent souvent plusieurs categories. En particulier, `Pet Supplies` apparait dans plusieurs paires de categories a fort revenu, notamment avec `Clothing`, `Beauty & Health`, `Grocery` et `Electronics`.

Ma recommandation est de tester des recommandations croisées autour de `Pet Supplies`, tout en suivant les profils `express_shipping`, `gift_wrapped` et `fragile` dans un tableau de bord operationnel. Le pilote peut viser un horizon de 8 semaines, avec un KPI cible de +3 % sur le panier moyen des commandes contenant `Pet Supplies`, sans degradation de la marge ni des delais de livraison.

## Décisions de modélisation

- **Grain de `fact_sales` :** une ligne de commande, identifiee par `(order_number, sale_line_id)`.
- **Dimension degeneree :** `order_number` reste dans `fact_sales`, car le numero de commande n'a pas d'attributs descriptifs propres.
- **Dimensions conformes existantes :** `fact_sales` reste reliee aux dimensions principales deja construites : `dim_date` via `date_key`, `dim_customer` via `customer_key`, `dim_product` via `product_key`, `dim_store` via `store_key` et `dim_channel` via `channel_key`.
- **Nouvelle dimension S04 :** `dim_order_profile` est ajoutee comme junk dimension via `order_profile_key`; elle regroupe les 8 drapeaux de commande en profils nommes.
- **Cle de jonction :** `fact_sales` conserve seulement `order_profile_key`, qui pointe vers `dim_order_profile`.
- **Flags exclus de la table de faits :** les colonnes `is_gift_wrapped`, `is_express_shipping`, `is_loyalty_redeemed`, `is_promo_applied`, `is_employee_purchase`, `is_online_pickup`, `is_fragile` et `is_oversized` ne sont pas stockees directement dans `fact_sales`.
- **Analyse de panier :** les paires de produits sont calculees par self-join de `fact_sales` sur `order_number`, avec `f1.product_key < f2.product_key` pour eviter les doublons inverses.

Cette decision respecte le principe Kimball : les petits indicateurs binaires ou de faible cardinalite sont regroupes dans une junk dimension afin de garder la table de faits compacte et lisible.

Exemples de granularite dans `dim_order_profile` :

| order_profile_key | is_gift_wrapped | is_express_shipping | is_loyalty_redeemed | is_fragile | is_oversized | profile_name |
|---:|---:|---:|---:|---:|---:|---|
| 1 | 0 | 0 | 0 | 0 | 0 | `standard_order` |
| 59 | 1 | 0 | 0 | 1 | 0 | `gift_wrapped + fragile` |

Ces exemples montrent que la cle de profil represente une combinaison de drapeaux, et non une ligne de commande individuelle.

## Preuve

**Profils operationnels**

La requete suivante agrège les ventes par profil de commande :

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

Top 5 observe :

| Profil | Commandes | Lignes | Revenu | Moyenne par ligne |
|---|---:|---:|---:|---:|
| `standard_order` | 118 | 374 | 87 055,52 $ | 232,77 $ |
| `loyalty_redeemed` | 66 | 218 | 45 600,89 $ | 209,18 $ |
| `express_shipping` | 45 | 142 | 30 741,56 $ | 216,49 $ |
| `gift_wrapped` | 39 | 134 | 29 028,91 $ | 216,63 $ |
| `fragile` | 36 | 126 | 28 874,76 $ | 229,16 $ |

**Observation** : les profils les plus frequents sont des commandes standards ou avec un seul drapeau actif. Cela donne aux operations des segments simples a surveiller : standard, fidelite, express, cadeau et fragile.

**Paires de produits co-achetées**

La requete suivante trouve les produits achetes ensemble dans une même commande :

```sql
SELECT
    pa.product_name AS product_a_name,
    pb.product_name AS product_b_name,
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
GROUP BY pa.product_name, pb.product_name
ORDER BY baskets_together DESC, pair_line_revenue DESC
LIMIT 20;
```

Top 5 observe :

| Produit A | Produit B | Paniers ensemble | Revenu associe |
|---|---|---:|---:|
| Electronics Item 9 | Pet Supplies Item 10 | 7 | 3 790,31 $ |
| Clothing Item 8 | Pet Supplies Item 3 | 7 | 3 531,59 $ |
| Home & Garden Item 4 | Beauty & Health Item 7 | 7 | 2 560,12 $ |
| Home & Garden Item 3 | Sports & Outdoors Item 7 | 7 | 2 018,15 $ |
| Electronics Item 3 | Beauty & Health Item 10 | 7 | 1 770,95 $ |

**Observation** : les cinq premieres paires apparaissent chacune dans 7 paniers. La meilleure paire en revenu est `Electronics Item 9` avec `Pet Supplies Item 10`, pour 3 790,31 $.

**Paires de categories**

| Categorie A | Categorie B | Paniers ensemble | Revenu associe |
|---|---|---:|---:|
| Clothing | Sports & Outdoors | 78 | 24 498,95 $ |
| Clothing | Pet Supplies | 65 | 41 915,33 $ |
| Clothing | Grocery | 61 | 22 786,96 $ |
| Electronics | Sports & Outdoors | 60 | 15 276,54 $ |
| Electronics | Pet Supplies | 55 | 32 689,96 $ |

**Observation** : `Clothing + Sports & Outdoors` est la paire la plus frequente, mais `Clothing + Pet Supplies` genere le revenu le plus eleve dans le top. `Pet Supplies` revient dans plusieurs associations a fort revenu et merite donc un test de ventes croisees.

## Validation

Les controles suivants ont ete executes apres la mise a jour de `fact_sales` et la creation de `dim_order_profile`.

| Controle | Resultat |
|---|---:|
| Lignes dans `fact_sales` | 2 147 |
| Commandes distinctes | 667 |
| Profils utilises dans `fact_sales` | 95 |
| Profils observes dans `dim_order_profile` | 97 |
| `order_profile_key` nulles | 0 |
| Cles `order_profile_key` orphelines | 0 |
| Doublons au grain `(order_number, sale_line_id)` | 0 |
| Lignes `raw_fact_sales` vs `fact_sales` | 2 147 = 2 147 |
| Self-pairs dans l'analyse panier | 0 |
| Flags `raw_orders` nuls ou hors domaine `0/1` | 0 |
| Profils rares avec une seule commande | controles par distribution |

Requetes de validation principales :

```sql
SELECT
    COUNT(*) AS fact_rows,
    COUNT(DISTINCT order_number) AS orders,
    COUNT(DISTINCT order_profile_key) AS profiles_used,
    COUNT(*) FILTER (WHERE order_profile_key IS NULL) AS null_profile_keys
FROM fact_sales;
```

Resultat : **2 147** lignes de faits, **667** commandes, **95** profils utilises et **0** cle de profil nulle.

```sql
SELECT
    'orphan_order_profile_key' AS check_name,
    COUNT(*) AS orphan_keys,
    CASE WHEN COUNT(*) = 0 THEN 'PASS' ELSE 'FAIL' END AS result
FROM fact_sales f
LEFT JOIN dim_order_profile op
    ON op.order_profile_key = f.order_profile_key
WHERE op.order_profile_key IS NULL;
```

Resultat : 0 cle orpheline, donc l'integrite referentielle entre `fact_sales` et `dim_order_profile` est valide.


```sql
WITH flag_quality AS (
    SELECT 'is_gift_wrapped' AS flag_name, COUNT(*) FILTER (WHERE is_gift_wrapped IS NULL) AS null_flags, COUNT(*) FILTER (WHERE CAST(is_gift_wrapped AS INTEGER) NOT IN (0, 1)) AS out_of_domain_flags FROM raw_orders
    UNION ALL
    SELECT 'is_express_shipping', COUNT(*) FILTER (WHERE is_express_shipping IS NULL), COUNT(*) FILTER (WHERE CAST(is_express_shipping AS INTEGER) NOT IN (0, 1)) FROM raw_orders
    UNION ALL
    SELECT 'is_loyalty_redeemed', COUNT(*) FILTER (WHERE is_loyalty_redeemed IS NULL), COUNT(*) FILTER (WHERE CAST(is_loyalty_redeemed AS INTEGER) NOT IN (0, 1)) FROM raw_orders
    UNION ALL
    SELECT 'is_promo_applied', COUNT(*) FILTER (WHERE is_promo_applied IS NULL), COUNT(*) FILTER (WHERE CAST(is_promo_applied AS INTEGER) NOT IN (0, 1)) FROM raw_orders
    UNION ALL
    SELECT 'is_employee_purchase', COUNT(*) FILTER (WHERE is_employee_purchase IS NULL), COUNT(*) FILTER (WHERE CAST(is_employee_purchase AS INTEGER) NOT IN (0, 1)) FROM raw_orders
    UNION ALL
    SELECT 'is_online_pickup', COUNT(*) FILTER (WHERE is_online_pickup IS NULL), COUNT(*) FILTER (WHERE CAST(is_online_pickup AS INTEGER) NOT IN (0, 1)) FROM raw_orders
    UNION ALL
    SELECT 'is_fragile', COUNT(*) FILTER (WHERE is_fragile IS NULL), COUNT(*) FILTER (WHERE CAST(is_fragile AS INTEGER) NOT IN (0, 1)) FROM raw_orders
    UNION ALL
    SELECT 'is_oversized', COUNT(*) FILTER (WHERE is_oversized IS NULL), COUNT(*) FILTER (WHERE CAST(is_oversized AS INTEGER) NOT IN (0, 1)) FROM raw_orders
)
SELECT
    SUM(null_flags) AS total_null_flags,
    SUM(out_of_domain_flags) AS total_out_of_domain_flags
FROM flag_quality;
```

Resultat : 0 flag nul et 0 flag hors domaine `0/1`.

## Risques / limites

- Les donnees sont synthetiques ; les resultats doivent etre confirmes avec des donnees de production avant decision commerciale.
- Les cinq meilleures paires de produits ont la meme frequence, soit 7 paniers. Le classement par revenu aide a prioriser, mais l'ecart de frequence reste faible.
- Une co-occurrence dans le panier ne prouve pas une relation causale. Il faut tester les recommandations avant de generaliser.
- La junk dimension contient les profils observes dans le seed actuel. Si les processus operationnels changent, de nouvelles combinaisons de flags peuvent apparaitre.
- `Pet Supplies` est prometteur dans les donnees actuelles, mais les promotions croisees doivent etre mesurees avec marge, stock et capacite logistique.

## Prochaine recommandation

Lancer un pilote de recommandations croisees autour de `Pet Supplies`, en priorisant les associations avec `Clothing`, `Beauty & Health`, `Grocery` et `Electronics`. En parallele, creer un tableau de bord operationnel par `profile_name` pour suivre les volumes de commandes standards, express, cadeau et fragile.

La prochaine iteration devrait mesurer si ces recommandations augmentent le panier moyen sans degrader les delais de livraison ni la marge.


## Traçabilité

Les requetes ont ete executees manuellement dans DuckDB et les resultats ont ete reportes dans ce brief apres verification des controles d'integrite. L'usage de l'IA est documente dans `ai-usage.md`; les livrables S04 ont ete commits progressivement, notamment `S04 basket-flags-walkthrough`, `S04 readme + update ai-usage` et les ajouts d'analyse/brief associes.
