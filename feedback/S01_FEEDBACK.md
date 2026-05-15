# Rétroaction automatisée -- S01 (Diagnostic fondamental -- NexaMart kickoff)

_Générée le 2026-05-15T12:34:06+00:00 -- Run `20260515T122624Z-00a5a04f`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

> ⚠️ **Avertissement instructeur (à retirer avant publication) :** cette analyse a été générée avec `--skip-pull`. Le contenu correspond au commit local et **n'est peut-être pas la dernière version poussée par l'étudiant·e**.

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief n'a pas pu être validée automatiquement. Quelques pistes constructives ci-dessous pour vous aider à la rendre exécutable et alignee avec la question posée.

_Observation technique : colonnes manquantes (oracle): quarter_

<details><summary>Requête analysée — cliquez pour déplier</summary>

```sql
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
```

</details>

- Colonnes retournées : `category, region, avg_discount, revenue, n_lines, avg_ticket`
- Correspondance avec les colonnes attendues :
  - `category` → `category`
  - `region` → `region`
  - `quarter` → `(à ajouter ou renommer)`
  - `revenue` → `revenue`

**Pistes :**
> Requête extraite par LLM (aucun bloc fencé détecté). Encadrez votre requête finale par ```sql ... ``` pour éliminer toute ambiguïté.
> Synonymes acceptés par colonne:
  category: ['category', 'categorie', 'p.category', 'sous_categorie']
  region: ['region', 's.region']
  quarter: ['quarter', 'trimestre', 'd.quarter', 'q']
  revenue: ['net_revenue', 'revenue', 'revenu', 'total_revenue', 'ca', 'sales', 'line_total', 'gross_revenue']

## 2. Rétroaction pédagogique sur le brief

> Le livrable identifie correctement le grain, les dimensions et présente des validations SQL pertinentes, ce qui permet d'obtenir des premiers diagnostics région-catégorie. Pour monter d'un cran, formalisez les risques architecturaux (SCD, non-additivité des prix), ajoutez des checks de cas limites et fournissez un historique de commits plus complet pour la traçabilité et la reproductibilité.

### Observations par dimension

**Model quality**
- Observation : Déclare un grain («une ligne dans la table raw_fact_sales représente une vente d'un produit dans un magasin») et liste les dimensions et mesures à agréger par catégorie/région/période.
- Piste d'amélioration : Précisez et justifiez le pattern SCD (p.ex. SCD Type 2 pour dim_product) et mentionnez les pièges (unit_price non-additif) pour montrer que le modèle tient à long terme.

**Validation quality**
- Observation : Fournit des contrôles SQL (counts, checks d'intégrité référentielle, agrégations GROUP BY) et un exemple de requête qui identifie catégories/regions faibles.
- Piste d'amélioration : Ajoutez des vérifications des cas limites (NULLs, doublons du grain, vérification que SUM(quantity*unit_price) = revenue attendu) et documentez les résultats attendus pour chaque check.

**Executive justification**
- Observation : Réponse exécutive liste catégories et régions concernées et propose des causes possibles (remises, saisonnalité) en langage non technique.
- Piste d'amélioration : Formulez une recommandation claire et priorisée pour le CEO (ex. valider investigation promotions vs stock sur X régions) et resserrez le texte à 150–300 mots sans fautes pour faciliter la décision.

**Process trace**
- Observation : Mentionne l'exécution de make generate/load/check mais n'inclut aucun historique git ni note IA sur les outils ou validations humaines.
- Piste d'amélioration : Ajoutez un journal de commits (≥3 commits incrémentaux avec messages) et une note IA précisant outils utilisés et quelle validation humaine a été faite.

**Reproducibility**
- Observation : Liste les requêtes exécutées et montre des outputs, mais le brief n'inclut pas d'instructions README ou script de check reproductible pour clonage.
- Piste d'amélioration : Fournissez un README minimal et un script make check reproduisible (chemins relatifs, dépendances listées) pour qu'un pair reproduise les résultats en <5 minutes.

## 3. Déclaration d'utilisation de l'IA

> La déclaration décrit clairement quand et comment l'IA a été utilisée et comment les sorties ont été vérifiées manuellement. Il manque cependant une identification précise des versions/modèles de l'outil et l'absence d'une section sur les limites ou erreurs observées réduit la complétude.

**Sujets bien couverts dans votre déclaration :**

- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain

**Sujets à ajouter ou expliciter pour la prochaine itération :**

- outils utilisés (nom + version/modèle)
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Reprendre la requête de la section « Preuve » pour qu'elle s'exécute sur `db/nexamart.duckdb` et qu'elle produise la forme attendue (voir pistes en section 1).
- Compléter `ai-usage.md` en y ajoutant : outils utilisés (nom + version/modèle).
- Compléter `ai-usage.md` en y ajoutant : limites ou erreurs observées.

---

## 5. Traçabilité

- **Run ID :** `20260515T122624Z-00a5a04f`
- **Devoir :** `S01`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `49e1925`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260515T122624Z-00a5a04f/NoumSandji/`
- **Prompts (SHA-256) :**
  - `sql_extractor_system` : `90ee9e277de7a27f...`
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
