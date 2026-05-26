# Rétroaction automatisée -- S03 (Dimensions à changement lent : garder la vérité historique chez NexaMart)

_Générée le 2026-05-26T01:06:19+00:00 -- Run `20260526T010307Z-64bc65ed`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

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

> Brief clair et orienté business : la recommandation SCD2 pour la région est bien justifiée et la validation montre une méthode reproductible. Améliorer la traçabilité (commits git, note IA) et fournir résultats non redacted pour renforcer la validation et la confiance du board.

### Observations par dimension

**Model quality**
- Observation : Le brief précise le grain (ligne de commande), les mesures (line_total, margin_amount) et recommande SCD Type 2 pour dim_store.region.
- Piste d'amélioration : Préciser le pattern exact appliqué (ex. clé substitut, surrogate key) et montrer l'usage de version_num/effective_from dans un schéma synthétique pour lever toute ambiguïté structurelle.

**Validation quality**
- Observation : L'auteur fournit les requêtes SQL pour les rapports avant/après et décrit le reset de la base entre tests (make reset && make load).
- Piste d'amélioration : Inclure un extrait d'une exécution réelle (résultats non redacted) et ajouter des checks de cas limites (NULLs, SUM = 0, vérification du mapping store_key) pour renforcer la validation.

**Executive justification**
- Observation : La réponse exécutive dit clairement que les changements impactant la performance doivent être historisés et recommande SCD2 pour la région, avec une justification business lisible.
- Piste d'amélioration : Ajouter un court chiffre-clé ou pourcentage attendu d'impact (ex. écart régional estimé) pour rendre la décision encore plus actionnable pour le conseil.

**Process trace**
- Observation : La section Validation liste les commandes exécutées mais il n'y a pas d'historique git ni de note IA détaillée.
- Piste d'amélioration : Ajouter un log de commits git (≥3 commits) avec messages descriptifs et une brève note IA indiquant l'outil utilisé et la validation humaine effectuée.

**Reproducibility**
- Observation : Le brief fournit les commandes make et la commande duckdb pour reproduire les tests (make reset; make load; duckdb ...).
- Piste d'amélioration : Documenter dans le README les chemins attendus et tout paramètre à ajuster (chemin vers db/, variables d'environnement) pour une reproduction sans ambiguïté.

## 3. Déclaration d'utilisation de l'IA

> La déclaration couvre bien les quatre thèmes demandés : outils, étapes d'utilisation, validation humaine et limites observées. Toutefois, certaines mentions d'outils restent génériques (par ex. "GitHub Copilot chat" sans version précise), ce qui empêche d'attribuer la note maximale.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Aucune correction technique nécessaire. Voir la section 2 pour des pistes d'approfondissement.

---

## 5. Traçabilité

- **Run ID :** `20260526T010307Z-64bc65ed`
- **Devoir :** `S03`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `82d5be3`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260526T010307Z-64bc65ed/NoumSandji/`
- **Prompts (SHA-256) :**
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
  - `sql_extractor_system` : `90ee9e277de7a27f...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
