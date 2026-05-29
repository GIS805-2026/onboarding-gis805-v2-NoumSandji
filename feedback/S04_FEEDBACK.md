# Rétroaction automatisée -- S04 (Panier d'achat et drapeaux : les patterns que l'étoile simple ne couvre pas)

_Générée le 2026-05-29T13:00:36+00:00 -- Run `20260529T125432Z-0258cabb`_

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

> Très bon travail : le modèle est clair, les validations sont complètes et la recommandation exécutive est actionnable avec KPI et horizon. Pour compléter, fournissez un petit diagramme du schéma et un script de vérification automatisé pour faciliter la reproduction.

### Observations par dimension

**Model quality**
- Observation : Le brief précise le grain (ligne de commande), conserve order_number comme dimension dégénérée et décrit la création de dim_order_profile pour regrouper 8 flags en profils exploitables.
- Piste d'amélioration : Ajouter un diagramme de schéma (star schema) simple montrant fact_sales et dim_order_profile pour clarifier les jointures et les clés.

**Validation quality**
- Observation : Le document fournit plusieurs requêtes de contrôle (comptages, clés orphelines, vérification des flags 0/1) et un tableau de résultats montrant 0 clés orphelines et 0 flags hors domaine.
- Piste d'amélioration : Inclure une requête de validation montrant l'absence de duplication de profils rares et un test sur les NULLs après la création de dim_order_profile.

**Executive justification**
- Observation : La section 'Réponse exécutive' propose une recommandation claire: piloter des recommandations croisées autour de Pet Supplies sur 8 semaines avec un KPI cible de +3 % sur le panier moyen.
- Piste d'amélioration : Ajouter une estimation concise de l'impact financier attendu (p. ex. lift en CA) et le seuil d'acceptation pour décider du déploiement.

**Process trace**
- Observation : La traçabilité mentionne des commits progressifs nommés (ex. 'S04 basket-flags-walkthrough', 'S04 readme + update ai-usage') et un fichier ai-usage.md documentant l'usage de l'IA.
- Piste d'amélioration : Joindre le log de commits (liste courte avec timestamps) ou pointer vers le repo pour vérification rapide.

**Reproducibility**
- Observation : Les requêtes ont été exécutées manuellement dans DuckDB et les résultats reportés, mais aucun script de 'check' automatisé n'est fourni pour exécuter la reproduction en un clic.
- Piste d'amélioration : Fournir un script de vérification (shell/SQL) ou un notebook DuckDB qui reproduit les contrôles principaux après clone.

## 3. Déclaration d'utilisation de l'IA

> La déclaration est détaillée et trace précisément quand et comment l'IA a été utilisée et validée par l'auteur. Cependant, certains outils sont décrits de façon générique (par ex. Copilot sans modèle/version), il faudrait préciser les versions/modèles lorsque possible.

**Sujets bien couverts dans votre déclaration :**

- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

**Sujets à ajouter ou expliciter pour la prochaine itération :**

- outils utilisés (nom + version/modèle)

## 4. Pistes d'action pour la prochaine itération

- Aucune correction technique nécessaire. Voir la section 2 pour des pistes d'approfondissement.

---

## 5. Traçabilité

- **Run ID :** `20260529T125432Z-0258cabb`
- **Devoir :** `S04`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `73fef43`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260529T125432Z-0258cabb/NoumSandji/`
- **Prompts (SHA-256) :**
  - `sql_extractor_system` : `90ee9e277de7a27f...`
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
