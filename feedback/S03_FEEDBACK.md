# Rétroaction automatisée -- S03 (Dimensions à changement lent : garder la vérité historique chez NexaMart)

_Générée le 2026-05-26T01:47:12+00:00 -- Run `20260526T014406Z-11c1baa8`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

> ⚠️ **Avertissement instructeur (à retirer avant publication) :** cette analyse a été générée avec `--skip-pull`. Le contenu correspond au commit local et **n'est peut-être pas la dernière version poussée par l'étudiant·e**.

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief n'a pas pu être validée automatiquement. Quelques pistes constructives ci-dessous pour vous aider à la rendre exécutable et alignee avec la question posée.

_Observation technique : aucun SELECT trouvé dans sql/scd/type1_vs_type2_demo.sql_


## 2. Rétroaction pédagogique sur le brief

> Le brief est solide : grain et mesures sont explicites, la recommandation SCD2 pour la région est claire et la validation SQL et les réconciliations sont convaincantes. Améliorez la traçabilité (commits git, note IA) et fournissez un schéma et tests automatiques pour rendre la solution entièrement reproductible en production.

### Observations par dimension

**Model quality**
- Observation : Le brief précise le grain (ligne de commande), les mesures (`line_total`, `margin_amount`) et recommande SCD Type 2 pour `dim_store.region` avec justification business.
- Piste d'amélioration : Précisez la gestion des clés substituts (store_key) et montrez un diagramme simple du schéma fact/dim pour éliminer toute ambiguïté structurelle.

**Validation quality**
- Observation : Le candidat fournit les requêtes SQL utilisées, la commande de test (`make reset && make load`) et trois contrôles de réconciliation (total ventes, marge, versions SCD2).
- Piste d'amélioration : Ajoutez un test automatique qui vérifie explicitement les cas limites (p. ex. division par zéro, NULLs sur dates d'effet) et capture les sorties numériques clés dans un fichier de preuve.

**Executive justification**
- Observation : La réponse exécutive dit clairement que «les changements qui influencent les rapports de performance doivent garder leur historique» et recommande SCD2 pour la région avec une action décisionnelle claire.
- Piste d'amélioration : Résumez en une ligne chiffrée l'impact attendu (ex. montant approximatif réattribué) pour renforcer l'urgence de la décision.

**Process trace**
- Observation : La validation mentionne les commandes utilisées (`make reset`, `make load`, `duckdb ...`) mais n'inclut pas d'historique git ni de note IA ou log de décision détaillé.
- Piste d'amélioration : Ajoutez un petit historique git (≥3 commits) avec messages significatifs et une note IA précisant l'outil et la validation humaine réalisée.

**Reproducibility**
- Observation : Le brief indique les commandes reproductibles (`make reset && make load` et l'exécution DuckDB) permettant de relancer les tests.
- Piste d'amélioration : Documentez explicitement les chemins relatifs attendus et ajoutez un script `check.sh` qui exécute toutes les validations et produit un rapport numérique.

## 3. Déclaration d'utilisation de l'IA

> La déclaration est complète : elle nomme les outils/modèles, précise les étapes d'utilisation, décrit les validations humaines et signale des erreurs concrètes. Bon travail de traçage et de preuve (ex. sorties de make load/check) — rien d'évidemment générique ou manquant.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Reprendre la requête de la section « Preuve » pour qu'elle s'exécute sur `db/nexamart.duckdb` et qu'elle produise la forme attendue (voir pistes en section 1).

---

## 5. Traçabilité

- **Run ID :** `20260526T014406Z-11c1baa8`
- **Devoir :** `S03`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `82d5be3`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260526T014406Z-11c1baa8/NoumSandji/`
- **Prompts (SHA-256) :**
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
