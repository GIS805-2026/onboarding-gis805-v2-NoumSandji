# Reproduction du modèle en étoile S02

Ce dossier contient les scripts SQL utilisés pour construire les dimensions et la table de faits du modèle en étoile NexaMart.

## Prérequis

- Avoir cloné le dépôt.
- Avoir DuckDB installé.
- Exécuter les commandes depuis la racine du dépôt.

## Étapes

1. Générer les données synthétiques :

```bash
make generate
```
2. Charger les données dans la base DuckDB :

```bash
make load
```
3. Validation des données générées:

```bash
make check
```
4. Créer les dimensions :

duckdb db/nexamart.duckdb < sql/dims/dim_product.sql
duckdb db/nexamart.duckdb < sql/dims/dim_customer.sql
duckdb db/nexamart.duckdb < sql/dims/dim_store.sql
duckdb db/nexamart.duckdb < sql/dims/dim_date.sql
duckdb db/nexamart.duckdb < sql/dims/dim_channel.sql

5. Créer la table de faits :

duckdb db/nexamart.duckdb < sql/facts/fact_sales.sql

6. Reproduire les resultats du brief:

Les requêtes utilisées pour valider le modèle et répondre à la question du CEO sont documentées dans: `answers/S02_executive_brief.md`

duckdb db/nexamart.duckdb < sql/facts/fact_sales.sql

## Résultat attendu

Après ces étapes, les tables suivantes doivent exister dans db/nexamart.duckdb :

`dim_product`
`dim_customer`
`dim_store`
`dim_date`
`dim_channel`
`fact_sales`

## Notes de reproductibilité

Les commandes utilisent des chemins relatifs au dépôt. La base attendue est `db/nexamart.duckdb`. Aucun chemin local absolu ne doit être nécessaire.


**“Éviter les clefs/chemins codés en dur”**, ça veut dire éviter des choses comme :

```text
C:\Users\ton_nom\Documents\...
/home/ton_nom/...
```
ou des valeurs fixes qui ne marchent que sur ta machine.

Il vaut mieux utiliser des chemins relatifs au projet :

`db/nexamart.duckdb`
`sql/dims/dim_product.sql`
`answers/S02_executive_brief.md`