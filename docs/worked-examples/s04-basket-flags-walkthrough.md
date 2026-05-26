# S04 -- Junk Dimension et Analyse de Panier

Ce walkthrough sert de procedure de travail pour la seance S04. Il couvre le modele de commandes NexaMart, la junk dimension des drapeaux operationnels, la mise a jour de `fact_sales`, l'analyse de panier et les validations a executer avant remise.

## Objectif du lab

Repondre a la question du CEO :

> Quels patterns de commande NexaMart sont importants pour les operations, et quels produits sont achetes ensemble ?

Le lab a deux volets :

- consolider les drapeaux de commande dans une junk dimension nommee ;
- analyser les paires de produits achetes dans un meme panier.

## Livrables attendus

- `sql/dims/dim_order_profile.sql`
- `sql/facts/fact_sales.sql`
- `sql/analysis/basket_pairs.sql`
- `answers/S04_executive_brief.md`
- `docs/schema-v2.md`
- optionnel : `docs/board-briefs/s04-basket-flags.md`

## 1. Verifier les sources S04

Les tables brutes attendues sont :

```sql
SHOW TABLES;
```

A confirmer :

```text
raw_orders
raw_order_lines
```

Verifier ensuite les colonnes :

```sql
DESCRIBE raw_orders;
DESCRIBE raw_order_lines;
```

Dans `raw_orders`, les 8 drapeaux attendus sont :

```text
is_gift_wrapped
is_express_shipping
is_loyalty_redeemed
is_promo_applied
is_employee_purchase
is_online_pickup
is_fragile
is_oversized
```

## 2. Verifier le grain des donnees S04

Une ligne de `raw_orders` doit representer une commande.

```sql
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT order_number) AS distinct_orders
FROM raw_orders;
```

Resultat attendu : `rows = distinct_orders`.

Une ligne de `raw_order_lines` doit representer une ligne de commande.

```sql
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT line_id) AS distinct_lines
FROM raw_order_lines;
```

## 3. Verifier les jointures commande/lignes

Chaque ligne de commande doit avoir une commande parent.

```sql
SELECT COUNT(*) AS orphan_order_lines
FROM raw_order_lines l
LEFT JOIN raw_orders o
    ON o.order_number = l.order_number
WHERE o.order_number IS NULL;
```

Resultat attendu : `orphan_order_lines = 0`.

## 4. Construire la junk dimension

Fichier : `sql/dims/dim_order_profile.sql`

La dimension doit contenir :

```text
order_profile_key
les 8 flags
profile_name
loaded_at
```

Principe : conserver seulement les combinaisons observees dans les donnees.

```sql
SELECT DISTINCT
    is_gift_wrapped,
    is_express_shipping,
    is_loyalty_redeemed,
    is_promo_applied,
    is_employee_purchase,
    is_online_pickup,
    is_fragile,
    is_oversized
FROM raw_orders;
```

Puis generer une cle substitut :

```sql
ROW_NUMBER() OVER (...) AS order_profile_key
```

Les noms de profils doivent etre lisibles pour un VP, par exemple :

```text
standard_order
gift_wrapped + loyalty_redeemed
online_pickup + fragile
```

## 5. Verifier la junk dimension

Nombre de combinaisons distinctes :

```sql
SELECT COUNT(*) AS profile_count
FROM dim_order_profile;
```

Dans le seed actuel, on a observe 97 profils distincts.

Verifier l'unicite de la cle :

```sql
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT order_profile_key) AS distinct_keys
FROM dim_order_profile;
```

Resultat attendu : `rows = distinct_keys`.

Verifier l'unicite des combinaisons de flags :

```sql
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT
        is_gift_wrapped || '-' ||
        is_express_shipping || '-' ||
        is_loyalty_redeemed || '-' ||
        is_promo_applied || '-' ||
        is_employee_purchase || '-' ||
        is_online_pickup || '-' ||
        is_fragile || '-' ||
        is_oversized
    ) AS distinct_flag_combinations
FROM dim_order_profile;
```

Resultat attendu : `rows = distinct_flag_combinations`.

## 6. Mettre a jour `fact_sales`

Fichier : `sql/facts/fact_sales.sql`

Ajouter seulement cette cle dans la table de faits :

```text
order_profile_key
```

Ne pas ajouter les 8 flags directement dans `fact_sales`. Le role de la junk dimension est justement d'eviter de polluer la table de faits avec des colonnes binaires de faible cardinalite.

Jointures necessaires :

```sql
JOIN raw_orders o
    ON o.order_number = f.order_number

JOIN dim_order_profile op
    ON op.is_gift_wrapped = o.is_gift_wrapped
   AND op.is_express_shipping = o.is_express_shipping
   AND op.is_loyalty_redeemed = o.is_loyalty_redeemed
   AND op.is_promo_applied = o.is_promo_applied
   AND op.is_employee_purchase = o.is_employee_purchase
   AND op.is_online_pickup = o.is_online_pickup
   AND op.is_fragile = o.is_fragile
   AND op.is_oversized = o.is_oversized
```

## 7. Verifier l'integrite de `fact_sales`

Aucune ligne ne doit perdre sa cle de profil :

```sql
SELECT
    COUNT(*) AS fact_rows,
    COUNT(*) FILTER (WHERE order_profile_key IS NULL) AS null_profile_keys
FROM fact_sales;
```

Resultat attendu : `null_profile_keys = 0`.

Verifier que le nombre de lignes n'a pas change :

```sql
SELECT
    (SELECT COUNT(*) FROM raw_fact_sales) AS raw_fact_rows,
    (SELECT COUNT(*) FROM fact_sales) AS fact_sales_rows;
```

Resultat attendu : `raw_fact_rows = fact_sales_rows`.

Verifier le grain :

```sql
SELECT
    order_number,
    sale_line_id,
    COUNT(*) AS n
FROM fact_sales
GROUP BY order_number, sale_line_id
HAVING COUNT(*) > 1;
```

Resultat attendu : aucune ligne.

## 8. Verifier la jointure vers la junk dimension

```sql
SELECT
    f.order_number,
    f.sale_line_id,
    f.order_profile_key,
    op.profile_name
FROM fact_sales f
JOIN dim_order_profile op
    ON op.order_profile_key = f.order_profile_key
ORDER BY f.order_number, f.sale_line_id
LIMIT 20;
```

Cette requete doit retourner des profils lisibles, par exemple `standard_order`, `employee_purchase`, ou `gift_wrapped + loyalty_redeemed`.

## 9. Analyser les profils operationnels

Cette requete fournit l'evidence 1 du brief.

```sql
SELECT
    op.profile_name,
    COUNT(DISTINCT f.order_number) AS orders,
    COUNT(*) AS order_lines,
    ROUND(SUM(f.line_total), 2) AS revenue
FROM fact_sales f
JOIN dim_order_profile op
    ON op.order_profile_key = f.order_profile_key
GROUP BY op.profile_name
ORDER BY orders DESC, revenue DESC
LIMIT 10;
```

## 10. Creer l'analyse de panier

Fichier : `sql/analysis/basket_pairs.sql`

La requete utilise une self-join sur `fact_sales` :

```sql
SELECT
    pa.name AS product_a,
    pb.name AS product_b,
    COUNT(DISTINCT f1.order_number) AS baskets_together
FROM fact_sales f1
JOIN fact_sales f2
    ON f1.order_number = f2.order_number
   AND f1.product_key < f2.product_key
JOIN dim_product pa
    ON pa.product_key = f1.product_key
JOIN dim_product pb
    ON pb.product_key = f2.product_key
GROUP BY pa.name, pb.name
ORDER BY baskets_together DESC
LIMIT 20;
```

Cette requete fournit l'evidence 2 du brief : les produits achetes ensemble.

## 11. Verifier l'analyse de panier

Controles importants :

- la requete ne doit pas retourner un produit avec lui-meme ;
- les paires ne doivent pas etre doublees en sens inverse ;
- la jointure doit utiliser `order_number`, pas `customer_id` ;
- le grain utilise doit rester la ligne de commande.

La condition importante est :

```sql
f1.product_key < f2.product_key
```

Elle evite de compter deux fois `(A, B)` et `(B, A)`.

## 12. Mettre a jour le schema

Fichier : `docs/schema-v2.md`

Documenter le modele apres S04.

Pour `fact_sales` :

```text
fact_sales
  Grain : une ligne de commande, identifiee par (order_number, sale_line_id)
  Dimension degeneree : order_number
  FK existantes :
    date_key -> dim_date
    customer_key -> dim_customer
    product_key -> dim_product
    store_key -> dim_store
    channel_key -> dim_channel
  Nouvelle FK S04 :
    order_profile_key -> dim_order_profile
```

Pour `dim_order_profile` :

```text
dim_order_profile
  Type : junk dimension
  Grain : une combinaison distincte des 8 flags de commande
  Cle substitut : order_profile_key
  Attributs :
    is_gift_wrapped
    is_express_shipping
    is_loyalty_redeemed
    is_promo_applied
    is_employee_purchase
    is_online_pickup
    is_fragile
    is_oversized
    profile_name
```

Point a expliciter dans le schema : les 8 flags ne sont pas stockes directement dans `fact_sales`; la table de faits garde seulement `order_profile_key`.

## 13. Rediger le brief S04

Fichier : `answers/S04_executive_brief.md`

Sections obligatoires :

```text
Question du CEO
Reponse executive
Decisions de modelisation
Preuve
Validation
Risques / limites
Prochaine recommandation
```

Le brief doit expliquer :

- `order_number` reste dans `fact_sales` comme dimension degeneree ;
- les 8 flags vont dans `dim_order_profile`, pas directement dans `fact_sales` ;
- il y a 97 combinaisons observees sur 256 possibles ;
- `fact_sales` garde seulement `order_profile_key` ;
- les paires de produits sont trouvees avec une self-join sur `order_number`.

## 14. Executer les validations

Recharger la base :

```bash
make load
```

Verifier :

```bash
make check
```

Attention : `make check` peut echouer sur des tables de seances futures non construites. Pour S04, les points importants sont :

```text
dim_order_profile exists
fact_sales exists
fact_sales grain unique
fact_sales FK not null
order_profile_key not null
```

## 15. Commit et push

Committer les fichiers source du lab :

```bash
git status
git add sql/dims/dim_order_profile.sql sql/facts/fact_sales.sql sql/analysis/basket_pairs.sql answers/S04_executive_brief.md docs/schema-v2.md docs/worked-examples/s04-basket-flags-walkthrough.md
git commit -m "S04 junk dimension and basket analysis"
git push
```

Si la base generee et les resultats de validation doivent aussi etre remis :

```bash
git add db/nexamart.duckdb validation/results/check_results.txt
git commit -m "Update S04 generated warehouse artifacts"
git push
```
