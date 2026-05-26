# Rétroaction automatisée -- S03 (Dimensions à changement lent : garder la vérité historique chez NexaMart)

_Générée le 2026-05-26T01:57:47+00:00 -- Run `20260526T015604Z-ec24ee45`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

> ⚠️ **Avertissement instructeur (à retirer avant publication) :** cette analyse a été générée avec `--skip-pull`. Le contenu correspond au commit local et **n'est peut-être pas la dernière version poussée par l'étudiant·e**.

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

> Bon travail : la recommandation business est claire et la validation SQL est solide, montrant que Type 2 conserve la vérité historique sans altérer les totaux. Améliorez la traçabilité (commits, note IA) et ajoutez un schéma/clarification des clés pour rendre le modèle immédiatement déployable.

### Observations par dimension

**Model quality**
- Observation : Le brief précise le grain (ligne de commande), les mesures (line_total, margin_amount) et recommande SCD Type 2 pour dim_store.region.
- Piste d'amélioration : Préciser la gestion des clés substituts (store_key) et documenter le pattern SCD (ex. version_num, jointure temporelle) avec un schéma ER pour lever toute ambiguïté structurelle.

**Validation quality**
- Observation : La validation inclut requêtes SQL avant/après, commande reproducible (make reset && make load) et trois contrôles : réconciliation des ventes, de la marge et vérification des versions SCD2.
- Piste d'amélioration : Ajouter des cas limites explicites et tests automatisés (NULLs, ventes à la frontière d'effective_date, clients sans store_key) pour renforcer la robustesse.

**Executive justification**
- Observation : La réponse exécutive dit clairement que «les changements qui influencent les rapports de performance doivent garder leur historique» et recommande d'historiser region en Type 2.
- Piste d'amélioration : Raccourcir et synthétiser la justification en 2–3 phrases chiffrées (impact attendu en dollars ou %) pour un board brief encore plus actionnable.

**Process trace**
- Observation : Le document décrit les commandes exécutées (make reset, make load, duckdb) mais n'inclut pas d'historique git ni de note IA détaillée.
- Piste d'amélioration : Fournir un log de commits (≥3) avec messages significatifs et une note IA précisant outil, prompt et validation humaine.

**Reproducibility**
- Observation : Les commandes et chemins (duckdb db/nexamart.duckdb, sql/scd/type1_vs_type2_demo.sql) sont fournis pour reproduire l'exécution.
- Piste d'amélioration : Documenter dans le README les pré-requis et vérifier qu'aucun chemin codé en dur n'empêche l'exécution sur un clone propre.

## 3. Déclaration d'utilisation de l'IA

> La déclaration est détaillée et suit le format exigé : modèles utilisés, prompts, validations et étapes sont bien documentés. Attention : certaines références d'outil restent génériques (ex. «GitHub Copilot chat» sans version précise), ce qui empêche la note maximale.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Aucune correction technique nécessaire. Voir la section 2 pour des pistes d'approfondissement.

---

## 5. Traçabilité

- **Run ID :** `20260526T015604Z-ec24ee45`
- **Devoir :** `S03`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `82d5be3`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260526T015604Z-ec24ee45/NoumSandji/`
- **Prompts (SHA-256) :**
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
