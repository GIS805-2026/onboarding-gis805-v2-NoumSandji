# Rétroaction automatisée -- S02 (Première étoile -- schéma en étoile, grain et dimensions conformes)

_Générée le 2026-05-22T00:22:42+00:00 -- Run `20260522T002131Z-cd9eaade`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief s'exécute correctement et produit la forme attendue. Bon travail sur l'auto-validation.

<details><summary>Requête analysée — cliquez pour déplier</summary>

```sql
SELECT
    p.category,
    s.region,
    d.quarter,
    SUM(f.line_total)   AS total_revenue,
    COUNT(*)             AS nb_lignes
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_store   s ON f.store_key   = s.store_key
JOIN dim_date    d ON f.date_key    = d.date_key
GROUP BY p.category, s.region, d.quarter
ORDER BY total_revenue DESC
LIMIT 10;
```

</details>

- Colonnes retournées : `category, region, quarter, total_revenue, nb_lignes`
- Correspondance avec les colonnes attendues :
  - `category` → `category`
  - `region` → `region`
  - `quarter` → `quarter`
  - `revenue` → `total_revenue`
- Présence de NULLs dans des colonnes de groupement : `category` =0, `region` =0, `quarter` =0. Pensez à documenter le traitement de ces cas.

## 2. Rétroaction pédagogique sur le brief

> Bon travail : le modèle en étoile, le grain et les requêtes de validation sont bien présentés et la section décisionnelle identifie des régions prioritaires. Pour atteindre l'excellence, harmonisez les clés, ajoutez des contrôles cas-limites et documentez l'historique git et les instructions de reproduction.

### Observations par dimension

**Model quality**
- Observation : Le brief décrit clairement le grain («1 ligne = 1 ligne de commande»), présente une étoile avec cinq dimensions conformées et liste les mesures additives et non-additives.
- Piste d'amélioration : Harmoniser les noms de clés entre le diagramme et les requêtes (p.ex. product_id vs product_key) et préciser le choix de pattern (SCD, role-playing) si nécessaire.

**Validation quality**
- Observation : Le document fournit une requête agrégée et une CTE utilisant LAG() pour mesurer le déclin trimestre sur trimestre.
- Piste d'amélioration : Ajouter des checks pour les cas limites (gestion des NULLs, validation du grain, vérification des totaux et des pondérations pour discount_pct) et montrer l'exécution sur un jeu de données représentatif.

**Executive justification**
- Observation : La section "Réponse au CEO" résume les régions et catégories concernées et propose de prioriser une investigation complémentaire sur BC, Estrie et Outaouais.
- Piste d'amélioration : Formuler une recommandation décisionnelle plus précise (p.ex. actions prioritaires, KPI cibles et impact attendu) en 150–300 mots pour faciliter la prise de décision.

**Process trace**
- Observation : Le brief inclut un prompt Copilot et mentionne "création des tables...scripts .sql" mais n'indique pas d'historique de commits ni de log de décision détaillé.
- Piste d'amélioration : Fournir un historique git avec au moins 3 commits incrémentaux et une note IA spécifiant outil, rôle et validation humaine.

**Reproducibility**
- Observation : Le candidat indique l'existence de scripts .sql pour créer les tables, sans README ou instructions de reproduction détaillées.
- Piste d'amélioration : Ajouter un README avec instructions pas-à-pas (clone → exécuter scripts → reproduire les résultats) et éviter les clefs/chemins codés en dur.

## 3. Déclaration d'utilisation de l'IA

> La déclaration décrit clairement les outils et les usages étape par étape, et documente bien les validations humaines et les erreurs rencontrées. Toutefois, les versions/modèles précis des outils ne sont pas fournies (ex. numéro de version ou variante du modèle), ce qui rend la déclaration partiellement générique.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Aucune correction technique nécessaire. Voir la section 2 pour des pistes d'approfondissement.

---

## 5. Traçabilité

- **Run ID :** `20260522T002131Z-cd9eaade`
- **Devoir :** `S02`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `6c92e7f`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260522T002131Z-cd9eaade/NoumSandji/`
- **Prompts (SHA-256) :**
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
