# Reproduction S03 - SCD Type 1 vs Type 2

Ce dossier contient la demonstration S03 sur les dimensions a changement lent
dans NexaMart.

Le fichier principal est :

```text
sql/scd/type1_vs_type2_demo.sql
```

Il sert a comparer deux traitements du meme changement business :

```text
Le magasin Gatineau passe de la region Outaouais a la region Quebec
a partir du 2026-03-01.
```

## Prerequis

- Exécuter les commandes depuis la racine du depot.
- Avoir DuckDB disponible.
- Avoir genere et charge la base NexaMart.

## Preparation de la base

Depuis la racine du depot :

```bash
make reset
make generate
make load
make check
```

Si les donnees ont deja ete generees, il suffit generalement de faire :

```bash
make reset
make load
make check
```

La base attendue est :

```text
db/nexamart.duckdb
```

## Rapport de reference

Le premier rapport du script affiche les ventes, la marge totale et le
pourcentage de marge par region.

Commande recommandee pour obtenir un resultat en Markdown :

```bash
duckdb db/nexamart.duckdb -cmd ".headers on" -cmd ".mode markdown" < sql/scd/type1_vs_type2_demo.sql
```

Le pourcentage de marge est calcule avec :

```sql
100 * SUM(margin_amount) / SUM(line_total)
```

Il ne faut pas sommer des pourcentages ligne par ligne.

## Test SCD Type 1

Le Type 1 correspond a un `UPDATE` direct :

```sql
UPDATE dim_store
SET region = 'Quebec'
WHERE region = 'Outaouais'
  AND is_current = TRUE;
```

Resultat attendu :

```text
Outaouais disparait du rapport.
Ses ventes et sa marge sont reattribuees a Quebec.
```

Ce resultat montre le risque business du Type 1 : le rapport historique est
reecrit.

## Reset obligatoire avant Type 2

Le Type 1 modifie la table `dim_store`. Il ne faut donc pas enchainer Type 1
et Type 2 sur la meme base.

Avant de tester le Type 2 :

```bash
make reset
make load
```

Puis relancer le script avec le bloc Type 1 commente et le bloc Type 2 actif.

## Test SCD Type 2

Le Type 2 conserve l'ancienne version et insere une nouvelle version :

```text
ancienne version : Outaouais, end_date = 2026-02-28, is_current = false
nouvelle version : Quebec, effective_date = 2026-03-01, is_current = true
```

Resultat attendu :

```text
Outaouais reste visible pour les ventes historiques.
Quebec recoit seulement la nouvelle version du magasin.
```

Ce resultat montre que le Type 2 garde la verite historique.

## Resultats a reporter dans le brief

Reporter dans `answers/S03_executive_brief.md` :

- le rapport de reference avant changement;
- le rapport apres Type 1;
- le rapport apres Type 2;
- le montant de ventes et de marge qui serait reattribue avec Type 1;
- la recommandation business : historiser `dim_store.region` en Type 2.

## Notes de reproductibilite

- Utiliser uniquement des chemins relatifs au depot.
- Ne pas modifier manuellement `db/nexamart.duckdb`.
- Relancer `make reset && make load` avant chaque scenario destructif.
- Garder les observations SQL dans `sql/scd/type1_vs_type2_demo.sql` et
  l'interpretation business dans `answers/S03_executive_brief.md`.
