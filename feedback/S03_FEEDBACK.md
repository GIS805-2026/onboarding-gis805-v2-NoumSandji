# Rétroaction automatisée -- S03 (Dimensions à changement lent : garder la vérité historique chez NexaMart)

_Générée le 2026-05-25T22:09:51+00:00 -- Run `20260525T220643Z-3ddee3eb`_

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

> Le brief répond bien à la question CEO : grain et choix SCD pour dim_store sont explicités et des validations SQL sont fournies. Pour atteindre l'excellence, ajoutez des résultats chiffrés explicites, un historique de commits et des instructions de reproduction claires.

### Observations par dimension

**Model quality**
- Observation : Le brief énonce clairement le grain (ligne de commande), les mesures (line_total, margin_amount) et recommande SCD Type 2 pour dim_store.region.
- Piste d'amélioration : Préciser et justifier le pattern SCD choisi (colonnes effective_from/effective_to/version, gestion des fusions/role-playing) et montrer le DDL final du modèle produit.

**Validation quality**
- Observation : Le document inclut les requêtes SQL avant/après et mentionne l'exécution via make reset && make load et duckdb pour reproduire les tests.
- Piste d'amélioration : Ajouter des résultats chiffrés comparant avant/après (écart $ et %), et documenter le traitement des cas limites (NULLs, transactions hors plage, clés orphelines).

**Executive justification**
- Observation : La section 'Réponse exécutive' dit que les changements influençant les rapports de performance doivent être historisés et recommande de Type 2 pour la région, avec une justification métier concise.
- Piste d'amélioration : Formuler une recommandation décisionnelle plus directe pour le CA (ex. approbation explicite + impact attendu en $/%), en langage d'affaires et avec un court résumé chiffré.

**Process trace**
- Observation : La validation mentionne l'usage de make reset/make load et une réinitialisation entre tests, mais il n'y a aucune trace de commits git ni de note IA/usage d'outils.
- Piste d'amélioration : Inclure l'historique git (≥3 commits) avec messages, et une note IA précisant outil/usage et qui a validé manuellement les changements.

**Reproducibility**
- Observation : Les commandes d'exécution (duckdb db/nexamart.duckdb, make reset) sont fournies mais utilisent des chemins/artefacts qui peuvent être codés en dur.
- Piste d'amélioration : Fournir un README pas-à-pas montrant clone → commande unique pour reproduire (sans chemins codés en dur) et inclure un script check automatisé.

## 3. Déclaration d'utilisation de l'IA

> La déclaration couvre bien les quatre sujets requis : outils utilisés, étapes d'usage, validations humaines et erreurs observées. Cependant certaines mentions d'outils restent un peu vagues (ex. Copilot sans version précise), ce qui rend la déclaration partiellement générique.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Aucune correction technique nécessaire. Voir la section 2 pour des pistes d'approfondissement.

---

## 5. Traçabilité

- **Run ID :** `20260525T220643Z-3ddee3eb`
- **Devoir :** `S03`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `82d5be3`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260525T220643Z-3ddee3eb/NoumSandji/`
- **Prompts (SHA-256) :**
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
  - `sql_extractor_system` : `90ee9e277de7a27f...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
