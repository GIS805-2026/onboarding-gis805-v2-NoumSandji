# Rétroaction automatisée -- S04 (Panier d'achat et drapeaux : les patterns que l'étoile simple ne couvre pas)

_Générée le 2026-05-29T13:00:25+00:00 -- Run `20260529T125427Z-dfc5d65b`_

Ce document est produit par un pipeline reproductible (validation automatique du livrable + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief s'exécute correctement et produit la forme attendue. Bon travail sur l'auto-validation.

<details><summary>Requête analysée — cliquez pour déplier</summary>

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

</details>

- Colonnes retournées : `profile_label, n_orders, order_lines, revenue, avg_line_total`
- Correspondance avec les colonnes attendues :
  - `profile_label` → `profile_label`
  - `count` → `n_orders`
- Présence de NULLs dans des colonnes de groupement : `profile_label` =0. Pensez à documenter le traitement de ces cas.

## 2. Rétroaction pédagogique sur le brief

> Très bon travail : le modèle est cohérent, la junk-dimension est bien conçue et les validations sont complètes. La recommandation business est claire et actionnable ; ajouter des artefacts de reproduction et des métriques financières détaillées renforcera la décision du board.

### Observations par dimension

**Model quality**
- Observation : Le brief décrit clairement le grain (ligne de commande (order_number, sale_line_id)), la junk-dimension dim_order_profile et la clé de jonction order_profile_key.
- Piste d'amélioration : Ajouter un diagramme schématique (star schema) succinct pour rendre explicite les clés étrangères et faciliter la revue par l'équipe.

**Validation quality**
- Observation : Le document fournit plusieurs requêtes de contrôle (comptage de lignes, clés orphelines, tests de valeurs NULL/hors domaine) avec résultats (ex. 0 clés orphelines, 0 flags nuls).
- Piste d'amélioration : Inclure un script de test automatisé (SQL ou CI) qui exécute ces contrôles pour pouvoir répéter les validations à chaque changement.

**Executive justification**
- Observation : La section 'Réponse exécutive' formule une recommandation concrète (pilote 8 semaines, KPI +3% panier moyen pour Pet Supplies) et priorise les profils opérationnels à suivre.
- Piste d'amélioration : Préciser l'impact attendu en valeur absolue (ex. Δ revenu attendu) et le coût opérationnel estimé pour le pilote afin d'éclairer la décision du board.

**Process trace**
- Observation : La traçabilité indique que les requêtes ont été exécutées dans DuckDB, que l'usage de l'IA est documenté dans ai-usage.md et que des commits progressifs ont été faits (noms de commits listés).
- Piste d'amélioration : Joindre l'historique git (extraits de logs) ou un lien vers le repo / commits clés pour faciliter l'audit.

**Reproducibility**
- Observation : Le brief indique que les requêtes ont été exécutées manuellement dans DuckDB et que les livrables ont été committés, mais aucun script de reproduction automatisé n'est fourni.
- Piste d'amélioration : Fournir un script 'run_checks.sh' ou un notebook/DuckDB script et un README avec les étapes exactes pour reproduire les analyses sur un clone propre.

## 3. Déclaration d'utilisation de l'IA

> La déclaration documente abondamment les interactions IA, les étapes d'utilisation et les validations manuelles. Cependant plusieurs mentions d'outils restent génériques (ex. Copilot sans modèle/version), ce qui empêche l'obtention du score maximal.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Aucune correction technique nécessaire. Voir la section 2 pour des pistes d'approfondissement.

---

## 5. Traçabilité

- **Run ID :** `20260529T125427Z-dfc5d65b`
- **Devoir :** `S04`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `73fef43`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260529T125427Z-dfc5d65b/NoumSandji/`
- **Prompts (SHA-256) :**
  - `sql_extractor_system` : `90ee9e277de7a27f...`
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
