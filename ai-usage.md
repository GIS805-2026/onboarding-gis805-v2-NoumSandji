# Trace d'usage IA — GIS805

> Chaque interaction significative avec un outil IA doit être documentée ici.
> Ce fichier est **obligatoire** et évalué à chaque remise.

## Format par entrée

```
### YYYY-MM-DD — Séance SXX
- **Modèle :** (ChatGPT-4o, Claude, Copilot, etc.)
- **Prompt :** (copier-coller exact)
- **Résultat :** (résumé de ce que l'IA a produit)
- **Validation :** (comment vous avez vérifié/modifié le résultat)
- **Justification :** (pourquoi cette interaction était nécessaire)
```

---

<!-- Ajoutez vos entrées ci-dessous -->
### 2026-05-10 - séance S01
- **modèle :** GitHub  Copilot chat
- **prompt :**  "c'est quoi la différence entre c'est 03 commandes?"
- **Resultat :**make generate : Génère vos données fictives uniques (fichiers CSV dans synthetic) à partir de scripts Python, en simulant des ventes, clients et produits pour NexaMart. C'est la base pour tout le cours — sans cela, pas de données à analyser.

make load : Charge ces CSV dans DuckDB (votre entrepôt), créant des tables brutes (staging) prêtes pour les transformations Kimball. Cela transforme les fichiers plats en base de données relationnelle.

make check : Exécute des vérifications automatiques (dans validation) pour s'assurer que les données chargées sont cohérentes (ex. : pas de valeurs nulles critiques, clés uniques). Si tout passe, vous avez un environnement propre pour le diagnostic.

- **Validation :** J'ai comparé la réponse avec le resultat de mon exécution de commande
- **Justification :** je voulais comprendre le fonctionnement de ces commandes

- **modèle :** GitHub  Copilot chat
- **prompt :** mais lorsque j'ai fait le make generate je n'ai pas dans la trace les fichiers cvs raw_..."
- **Resultat :**Les fichiers CSV générés par make generate sont nommés avec le préfixe dim_ (ex. : dim_customer.csv, dim_product.csv) et placés dans data/synthetic/team_<votre_seed>/shared/, pas raw_. Ils simulent les données brutes des systèmes OLTP (dimensions de base pour clients, produits, dates, etc.), sans les faits de ventes encore.

Si vous ne les voyez pas dans la trace du terminal, c'est normal — make generate écrit silencieusement les fichiers. Vérifiez le dossier shared : vous devriez y trouver dim_channel.csv, dim_customer.csv, etc.

Pour le diagnostic S01, ces dimensions représentent les "systèmes opérationnels" : ils enregistrent les entités (clients, produits), mais pas les mesures analytiques (ventes par région/catégorie).

- **Validation :** j'ai parcourru les répertoires listés pour avoir les mêmes informations fournies par l'agent
- **Justification :** je voulais comprendre comment et où proviennent les données générées

- **modèle :** GitHub  Copilot chat
- **prompt :** "mais lorsque je fais le load, j'ai des fichiers raw_... qui sont chargés dans duckdb, d'ou viennent-ils?"
- **Resultat :**D’où viennent les raw_... ?
Quand vous lancez make load, le pipeline Python dans run_pipeline.py fait ceci :

Il parcourt tous les CSV sous synthetic
Pour chaque fichier *.csv, il calcule un nom de table DuckDB :
dim_customer.csv → raw_dim_customer
fact_sales.csv → raw_fact_sales
Il crée dans nexamart.duckdb une table DuckDB raw_<stem> en important le CSV avec read_csv_auto(...)
Donc :

raw_dim_customer n’est pas un fichier sur disque
c’est une table DuckDB créée automatiquement à partir de data/synthetic/.../dim_customer.csv

- **Validation :** j'ai parcourru les répertoires listés pour avoir les mêmes informations fournies par l'agent
- **Justification :** je voulais comprendre comment et où proviennent les données générées


- **modèle :** GitHub  Copilot chat
- **prompt :** " maintenant on va poursuivre avec notre diagnostique des données transactionnelles pour répondre à la question du CEO. quel est le plan que tu me proposes? est ce qu'on ne va pas commencer pas bien comprendre la question du CEO avant de d'aller en profondeur dans le diagnostique"
- **Resultat :** Oui, commencer par bien comprendre la question du CEO est essentiel : cela définit ce que tu cherches dans les données, avant de plonger dans le diagnostic. La question est "Quelles catégories déclinent dans quelles régions et pourquoi ?", ce qui se traduit en Kimball par :

Mesure : déclin des ventes (additive, par trimestre).
Dimensions : catégorie (produit), région (magasin), temps (trimestre).
Pourquoi : causes possibles (promo, retours, stock, etc.).
Plan proposé pour ton diagnostic S01
Clarifier la question : Reformule-la en termes de mesures/dimensions/hiérarchies. (2-3 min)
Inventorier les tables brutes : Liste les raw_* disponibles et leurs colonnes clés. (5 min)
Tester les dimensions : Vérifie si catégorie, région, trimestre existent et sont normalisées. (5 min)
Évaluer les mesures et jointures : Vois si les ventes sont jointables et si des causes sont présentes. (5 min)
Faire un test agrégé : Essaie une requête simple pour voir si la réponse partielle est possible. (5 min)
Rédiger le diagnostic : Note ce qui fonctionne, ce qui manque, et recommande le modèle Kimball. (5 min)

- **Validation :** exécution des requêtes fournies
SHOW TABLES;
DESCRIBE raw_dim_product;
DESCRIBE raw_dim_store;
DESCRIBE raw_dim_date;
DESCRIBE raw_fact_sales;

SELECT DISTINCT category FROM raw_dim_product;
SELECT DISTINCT region FROM raw_dim_store;
SELECT DISTINCT quarter FROM raw_dim_date ORDER BY quarter;

SELECT COUNT(*) FROM raw_fact_sales;
SELECT COUNT(*) FROM raw_fact_sales WHERE product_id NOT IN (SELECT product_id FROM raw_dim_product);

SELECT p.category, s.region, d.quarter, SUM(f.line_total) AS revenue
FROM raw_fact_sales f
JOIN raw_dim_product p ON p.product_id = f.product_id
JOIN raw_dim_store s ON s.store_id = f.store_id
JOIN raw_dim_date d ON d.date_key = f.order_date
GROUP BY p.category, s.region, d.quarter
ORDER BY revenue DESC
LIMIT 10;
- **Justification :** être sûre que les donnons contiennent tous les éléments nécessaires pour la réponse à question du CEO