# Rétroaction automatisée -- S04 (Panier d'achat et drapeaux : les patterns que l'étoile simple ne couvre pas)

_Générée le 2026-05-28T19:10:29+00:00 -- Run `20260528T190711Z-122cea87`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

> ⚠️ **Avertissement instructeur (à retirer avant publication) :** cette analyse a été générée avec `--skip-pull`. Le contenu correspond au commit local et **n'est peut-être pas la dernière version poussée par l'étudiant·e**.

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief n'a pas pu être validée automatiquement. Quelques pistes constructives ci-dessous pour vous aider à la rendre exécutable et alignee avec la question posée.

_Observation technique : colonnes manquantes (oracle): count_

<details><summary>Requête analysée — cliquez pour déplier</summary>

```sql
SELECT
    op.profile_name,
    COUNT(DISTINCT f.order_number) AS orders,
    COUNT(*) AS order_lines,
    ROUND(SUM(f.line_total), 2) AS revenue,
    ROUND(AVG(f.line_total), 2) AS avg_line_total
FROM fact_sales f
JOIN dim_order_profile op
    ON op.order_profile_key = f.order_profile_key
GROUP BY op.profile_name
ORDER BY orders DESC, revenue DESC
LIMIT 20;
```

</details>

- Colonnes retournées : `profile_name, orders, order_lines, revenue, avg_line_total`
- Correspondance avec les colonnes attendues :
  - `profile_label` → `profile_name`
  - `count` → `(à ajouter ou renommer)`

**Pistes :**
> Synonymes acceptés par colonne:
  profile_label: ['profile_label', 'label', 'profile', 'order_profile', 'basket_type', 'profil', 'nom_profil']
  count: ['n_orders', 'count', 'nb_orders', 'order_count', 'nombre_commandes', 'total_orders', 'nb_commandes']

## 2. Rétroaction pédagogique sur le brief

> Très bon brief technique et décisionnel : modèle clair (grain et junk dimension) et validations SQL complètes, avec des recommandations commerciales actionnables sur Pet Supplies et les profils opérationnels. Il manque cependant la traçabilité (commits/usage IA) et des instructions reproductibles pour un clone propre.

### Observations par dimension

**Model quality**
- Observation : Le brief décrit explicitement le grain (order_number, sale_line_id), la conservation de order_number comme dimension dégénérée et la création d'une junk dimension dim_order_profile pour regrouper les 8 drapeaux.
- Piste d'amélioration : Préciser un exemple concret de clé de profil (profile_key) et montrer un exemple de ligne de dim_order_profile pour illustrer la granularité des profils.

**Validation quality**
- Observation : Le candidat fournit des requêtes de validation, compte les lignes/factures, vérifie l'absence de clefs orphelines et signale 0 doublon au grain.
- Piste d'amélioration : Ajouter des checks explicites pour cas limites (valeurs NULLs sur flags, distributions extrêmes) et un test de sensibilité sur petits sous-échantillons.

**Executive justification**
- Observation : La section 'Réponse exécutive' formule une recommandation claire : piloter des recommandations croisées autour de Pet Supplies et créer un tableau de bord par profil opérationnel.
- Piste d'amélioration : Inclure un KPI cible chiffré (ex. augmentation attendue du panier moyen ou revenu) et un horizon temporel pour le pilote.

**Process trace**
- Observation : Aucune mention d'historique git, de commits incrémentaux ou d'une note sur l'usage d'IA n'apparaît dans le brief.
- Piste d'amélioration : Ajouter le log de commits git (≥3 commits avec messages) et une note IA précisant outil, rôle et validation humaine.

**Reproducibility**
- Observation : Le brief fournit les requêtes SQL de validation et d'analyse, mais il n'indique pas de README, scripts d'exécution automatiques ni instructions de configuration pour reproduire.
- Piste d'amélioration : Fournir un README pas-à-pas et un script d'initialisation (DuckDB ou autre) permettant d'exécuter les requêtes sur un clone propre.

## 3. Déclaration d'utilisation de l'IA

> La déclaration est complète : elle liste les outils employés, les étapes d'utilisation, les validations humaines et plusieurs erreurs rencontrées. Attention : certains libellés d'outil restent un peu génériques (p.ex. "GitHub Copilot chat" sans version), ce qui empêche d'atteindre la note maximale.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Reprendre la requête de la section « Preuve » pour qu'elle s'exécute sur `db/nexamart.duckdb` et qu'elle produise la forme attendue (voir pistes en section 1).

---

## 5. Traçabilité

- **Run ID :** `20260528T190711Z-122cea87`
- **Devoir :** `S04`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `f4f6825`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260528T190711Z-122cea87/NoumSandji/`
- **Prompts (SHA-256) :**
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
