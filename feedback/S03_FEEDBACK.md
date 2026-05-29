# Rétroaction automatisée -- S03 (Dimensions à changement lent : garder la vérité historique chez NexaMart)

_Générée le 2026-05-29T00:55:17+00:00 -- Run `20260529T004953Z-f2a5f6ff`_

Ce document est produit par un pipeline reproductible (validation automatique du livrable + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief s'exécute correctement et produit la forme attendue. Bon travail sur l'auto-validation.

<details><summary>Requête analysée — cliquez pour déplier</summary>

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

</details>

- Colonnes retournées : `region, total_sales, total_margin, margin_pct`
- Correspondance avec les colonnes attendues :
  - `region` → `region`
  - `revenue` → `total_sales`
- Présence de NULLs dans des colonnes de groupement : `region` =0. Pensez à documenter le traitement de ces cas.

## 2. Rétroaction pédagogique sur le brief

> Le brief répond clairement à la question CEO et recommande correctement SCD Type 2 pour la région du magasin, avec des validations SQL convaincantes. Il manque toutefois une traçabilité git et des résultats non redacted pour rendre la reproduction et la revue entièrement autonomes.

### Observations par dimension

**Model quality**
- Observation : Le brief précise le grain (order_number, sale_line_id), les mesures (line_total, margin_amount) et recommande SCD Type 2 pour dim_store.region avec clés naturelles et substitut.
- Piste d'amélioration : Ajouter un schéma ER ou un exemple de jointure temporelle (ON order_date BETWEEN effective_from AND effective_to) pour montrer explicitement comment les faits se lient aux versions.

**Validation quality**
- Observation : Le document inclut des requêtes SQL, procédures de test (make reset && make load) et contrôles (réconciliation des totaux, vérification des NULLs et des versions de store_key).
- Piste d'amélioration : Inclure les extraits de résultats chiffrés non redacted pour permettre une vérification directe des nombres et faciliter la revue.

**Executive justification**
- Observation : La section 'Réponse exécutive' répond à la question CEO en langage business et la 'Prochaine recommandation' donne une décision claire : historiser en Type 2 les changements qui modifient l'interprétation des ventes.
- Piste d'amélioration : Raccourcir légèrement pour rester dans un paragraphe de 150–300 mots et ajouter un indicateur quantifié (ex. % d'écart attendu) pour prioriser la décision.

**Process trace**
- Observation : Le brief mentionne des fichiers (docs/scd-store-schema.md) et les commandes make utilisées, mais n'indique pas d'historique git ni de note IA détaillée.
- Piste d'amélioration : Fournir l'historique git (≥3 commits significatifs) et une note IA précisant l'outil utilisé et comment les sorties ont été validées manuellement.

**Reproducibility**
- Observation : Les commandes make et la commande duckdb sont listées, permettant de reproduire les tests après un reset/load documenté.
- Piste d'amélioration : Ajouter un README minimal indiquant les chemins attendus, versions d'outils et étapes exactes pour exécuter le script sur un clone propre.

## 3. Déclaration d'utilisation de l'IA

> La déclaration couvre les quatre sujets demandés et donne de nombreux exemples concrets (prompts, commandes exécutées, résultats et vérifications). Cependant certaines mentions d'outils restent génériques (ex. Copilot sans modèle/version affichée, et affirmation d'un « GPT-5 » qui peut être imprécise).

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Aucune correction technique nécessaire. Voir la section 2 pour des pistes d'approfondissement.

---

## 5. Traçabilité

- **Run ID :** `20260529T004953Z-f2a5f6ff`
- **Devoir :** `S03`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `73fef43`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260529T004953Z-f2a5f6ff/NoumSandji/`
- **Prompts (SHA-256) :**
  - `sql_extractor_system` : `90ee9e277de7a27f...`
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
