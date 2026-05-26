# Rétroaction automatisée -- S03 (Dimensions à changement lent : garder la vérité historique chez NexaMart)

_Générée le 2026-05-26T01:52:02+00:00 -- Run `20260526T014859Z-8caeb97f`_

Ce document est produit par un pipeline reproductible (vérification SQL déterministe + analyse LLM du brief et de la déclaration IA). Une revue humaine précède toujours sa publication. **À ce stade expérimental, aucune note ni étiquette de niveau n'est diffusée : l'objectif est purement formatif.**

> ⚠️ **Avertissement instructeur (à retirer avant publication) :** cette analyse a été générée avec `--skip-pull`. Le contenu correspond au commit local et **n'est peut-être pas la dernière version poussée par l'étudiant·e**.

---

## 1. Vérification automatique de la requête SQL

La requête extraite de votre brief n'a pas pu être validée automatiquement. Quelques pistes constructives ci-dessous pour vous aider à la rendre exécutable et alignee avec la question posée.

_Observation technique : erreur d'exécution SQL: Catalog Error: Table with name scd_region_report_impact does not exist!_

<details><summary>Requête analysée — cliquez pour déplier</summary>

```sql
SELECT * FROM scd_region_report_impact LIMIT 100
```

</details>


**Pistes :**
> Tables référencées dans votre requête mais absentes de la base : `scd_region_report_impact`.
> Tables disponibles dans `db/nexamart.duckdb` : `dim_channel`, `dim_customer`, `dim_date`, `dim_product`, `dim_store`, `fact_sales`, `raw_bridge_campaign_allocation`, `raw_bridge_customer_segment`, `raw_customer_changes`, `raw_customer_profile_bands`, `raw_customer_scd3_history`, `raw_dim_channel`, `raw_dim_customer`, `raw_dim_date`, `raw_dim_geography`, `raw_dim_product`, `raw_dim_segment_outrigger`, `raw_dim_store`, `raw_fact_budget`, `raw_fact_daily_inventory`.

## 2. Rétroaction pédagogique sur le brief

> Le brief répond clairement à la question CEO et fournit une validation reproductible montrant que SCD Type 2 préserve la vérité historique pour la région du magasin. Pour atteindre l'excellence totale, ajoutez la traçabilité git/IA, formalisez quelques contrôles d'angles morts et condensez la justification exécutive en une recommandation chiffrée.

### Observations par dimension

**Model quality**
- Observation : Le brief précise le grain (order_number, sale_line_id), liste les mesures (line_total, margin_amount) et recommande SCD Type 2 pour dim_store.region en justifiant par l'exemple de Gatineau.
- Piste d'amélioration : Préciser les colonnes SCD (effective_from/effective_to/is_current/version_num) et montrer la jointure temporelle exacte utilisée pour relier fact_sales à la bonne version de dim_store.

**Validation quality**
- Observation : La section Validation décrit l'exécution séparée des tests Type 1 et Type 2, l'usage de make reset && make load et trois contrôles de réconciliation (ventes totales, marge, versions du magasin).
- Piste d'amélioration : Ajouter des contrôles d'angles morts (dates qui se chevauchent, doublons de is_current, gestion des NULL) et un test automatisé qui valide l'absence de périodes qui se chevauchent.

**Executive justification**
- Observation : La réponse exécutive dit clairement que les attributs influençant les rapports de performance doivent être historisés et recommande explicitement Type 2 pour region, avec une recommandation business finale.
- Piste d'amélioration : Raccourcir et formuler la justification en 150–300 mots sur un ton board-level et inclure un impact quantifié (ex. $ ou % d'attribution régionale) si possible.

**Process trace**
- Observation : Le brief liste les commandes utilisées (make reset, make load, duckdb) mais n'inclut pas d'historique git ni de note IA/validation humaine détaillée.
- Piste d'amélioration : Ajouter un log de commits git (≥3 commits) avec messages explicites et une note IA précisant l'outil utilisé et la validation humaine effectuée.

**Reproducibility**
- Observation : Le dossier indique les commandes exactes (make reset, make load, duckdb ...) permettant de reproduire les tests sur la base fournie.
- Piste d'amélioration : Retirer les chemins codés en dur et inclure un README pas-à-pas avec les versions d'outil et les fichiers attendus pour garantir une exécution sur un clone propre.

## 3. Déclaration d'utilisation de l'IA

> La déclaration documente clairement les interactions (outil + prompt), les étapes d'utilisation et les vérifications humaines exécutées. Toutefois, quelques mentions d'outils restent génériques (p.ex. Copilot sans version précise), ce qui empêche une preuve totalement complète selon les critères.

**Sujets bien couverts dans votre déclaration :**

- outils utilisés (nom + version/modèle)
- à quelle étape l'IA a été utilisée
- comment la sortie a été validée par l'humain
- limites ou erreurs observées

## 4. Pistes d'action pour la prochaine itération

- Reprendre la requête de la section « Preuve » pour qu'elle s'exécute sur `db/nexamart.duckdb` et qu'elle produise la forme attendue (voir pistes en section 1).

---

## 5. Traçabilité

- **Run ID :** `20260526T014859Z-8caeb97f`
- **Devoir :** `S03`
- **Étudiant·e :** `NoumSandji`
- **Commit analysé :** `82d5be3`
- **Audit (côté instructeur) :** `tools/instructor/feedback_pipeline/audit/20260526T014859Z-8caeb97f/NoumSandji/`
- **Prompts (SHA-256) :**
  - `rubric_grader_system` : `505f32d1d8319d66...`
  - `ai_usage_grader_system` : `81cb7fdf89bda55a...`
- **Fournisseur (rubrique) :** `openai`
- **Fournisseur (IA-usage) :** `openai` (gpt-5-mini-2025-08-07)

_Ce feedback a été produit par un pipeline automatisé et **revu par l'équipe pédagogique avant publication**. Aucun chiffre ni étiquette de niveau n'est diffusé à ce stade expérimental : l'objectif est uniquement formatif. Ouvrez une issue dans ce dépôt pour toute question._
