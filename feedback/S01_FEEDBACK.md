# Rétroaction automatisée -- S01 (Diagnostic fondamental -- NexaMart kickoff)

_Générée le 2026-05-14T22:21:51+00:00 -- Run `20260514T221333Z-7d34bf6a`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief n'a pas pu être validée automatiquement. Quelques pistes constructives ci-dessous pour vous aider à la rendre exécutable et alignee avec la question posée.

_Observation technique : aucun bloc SQL fencé trouvé et extraction LLM échouée_


**Pistes :**
> Aucun bloc ```sql ... ``` détecté. Encadrez votre requête finale dans la section « Preuve » pour fiabiliser l'auto-validation.
> Extracteur LLM : Aucune requête dans le brief ne calcule le chiffre d'affaires agrégé par category, region ET quarter : la requête finale groupe uniquement par category et region, il manque la dimension 'quarter' attendue.

## 2. Rétroaction pédagogique sur le brief

> Brief bien documenté avec preuves de requêtes et un grain explicite; cependant l'argumentation exécutive manque d'une recommandation claire et la traçabilité (commits, note IA, checks reproductibles) est incomplète. Pour améliorer, formalisez les risques SCD et fournissez un plan de reproduction et des contrôles de qualité automatisés.

### Observations par dimension

**Model quality**
- Observation : Le brief indique un grain clair («une ligne dans la table raw_fact_sales représente une vente d'un produit dans un magasin») et liste mesures et dimensions ciblées.
- Piste d'amélioration : Précisez et justifiez le pattern SCD (ex. SCD Type 2) et les choix structurants (unit_price non-additif, clé du grain) pour couvrir les risques historiques.

**Validation quality**
- Observation : Le document inclut des requêtes et comptes (COUNT(*) sur raw_fact_sales = 2147, contrôles d'intégrité référentielle) et une requête d'agrégation par catégorie/region.
- Piste d'amélioration : Ajoutez des contrôles de cas limites (NULLs, doublons du grain, vérification que SUM(quantity*unit_price)=revenue attendu) et rendez les checks reproductibles (scripts make check affichant PASS/FAIL).

**Executive justification**
- Observation : La section «Réponse exécutive» énumère catégories qui déclinent et régions concernées mais reste descriptive («possiblement lié aux remises…») sans recommandation claire au CEO.
- Piste d'amélioration : Formulez une recommandation décisionnelle explicite (ex. prioriser enquête promotions vs stock pour BC) et ajoutez métriques chiffrées synthétiques pour appuyer l'action.

**Process trace**
- Observation : Le brief signale que «make generate, make load, make check ont été exécutés» mais n'inclut pas d'historique git ni de note d'usage IA ou log de décisions.
- Piste d'amélioration : Fournissez un journal de commits (≥3 commits avec messages) et une note IA précisant outils utilisés, prompts et validation humaine.

**Reproducibility**
- Observation : Des requêtes et sorties sont listées mais il n'y a pas de README ou scripts explicitant l'ordre exact pour reproduire (chemins et dépendances).
- Piste d'amélioration : Ajoutez un README minimal «Clone → make generate → make load → make check» avec versions d'outils et sans chemins codés en dur.

## 3. Déclaration d'utilisation de l'IA

> La déclaration documente clairement les interactions (outil nommé, prompts et validations pratiques). En revanche elle ne signale pas de limites ou d'erreurs observées et ne précise pas la version/modèle exact(e) de l'IA.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain

**Sujets à ajouter ou expliciter pour la prochaine itération :**

- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Reprendre la requête de la section « Preuve » pour qu'elle s'exécute sur `db/nexamart.duckdb` et qu'elle produise la forme attendue (voir pistes en section 1).
- Compléter `ai-usage.md` en y ajoutant : limites ou erreurs observées.

---

## 5. Traçabilité

- **Run ID :** `20260514T221333Z-7d34bf6a`
- **Devoir :** `S01`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `12566d0`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260514T221333Z-7d34bf6a/NoumSandji/`
- **Prompts (SHA-256) :**
  - `sql_extractor_system` : `90ee9e277de7a27f...`
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
