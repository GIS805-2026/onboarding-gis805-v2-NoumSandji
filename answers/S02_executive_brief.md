# Board Brief -- S02 : Première étoile
## Question du CEO
**Question du CEO :** Quelles catégories de produits déclinent dans quelles régions, par trimestre ? et pourquoi?

## Grain statement

**1 ligne = 1 ligne de commande** identifiée par `(order_number, sale_line_id)`, concernant un produit, effectuée par un client, dans un magasin, via un canal de vente, à une date donnée.

## Etoile construite

```mermaid
erDiagram
    DIM_DATE     ||--o{ FACT_SALES : "order_date"
    DIM_PRODUCT  ||--o{ FACT_SALES : "product_id"
    DIM_STORE    ||--o{ FACT_SALES : "store_id"
    DIM_CUSTOMER ||--o{ FACT_SALES : "customer_id"
    DIM_CHANNEL  ||--o{ FACT_SALES : "channel_id"

    FACT_SALES {
        string  order_number  "degenerate dimension"
        int     sale_line_id  "line identifier"
        int     product_id    FK
        int     store_id      FK
        int     customer_id   FK
        int     channel_id    FK
        date    order_date    FK
        int     quantity      "additive"
        decimal net_price     "additive"
        decimal line_total    "additive"
        decimal discount_pct  "non-additive"
    }

    DIM_DATE {
        date   date_key PK
        int    year
        string quarter
        int    month
    }

    DIM_PRODUCT {
        int    product_id PK
        string product_name
        string category
        string subcategory
    }

    DIM_STORE {
        int    store_id PK
        string store_name
        string region
        string province
    }

    DIM_CUSTOMER {
        int    customer_id PK
        string customer_name
        string segment
    }

    DIM_CHANNEL {
        int    channel_id PK
        string channel_name
    }
```
## Décisions de modélisation
**Description des dimensions**
Les dimensions ont été construites à partir des tables brutes `raw_dim_*`. Pour les dimensions `dim_product`, `dim_customer`, `dim_store` et `dim_channel`, une clé de substitution (`*_key`) a été ajoutée avec `ROW_NUMBER()`. Cette clé technique est générée dans l'entrepôt et sert aux jointures avec la table de faits `fact_sales`.

Les colonnes `*_id` sont conservées comme clés naturelles, car elles proviennent du système source. Par exemple, `product_id` identifie le produit dans les données opérationnelles, tandis que `product_key` identifie la ligne correspondante dans `dim_product` pour le modèle analytique.

L'utilisation de clés de substitution permet de stabiliser les jointures, de séparer le modèle analytique des identifiants sources et de préparer le modèle à gérer des changements futurs dans les dimensions, par exemple avec des dimensions à évolution lente.

- **dim_product** : décrit les produits vendus. Elle contient `product_key` comme clé de substitution et `product_id` comme clé naturelle. Les autres colonnes retenues sont `product_name`, `category`, `subcategory`, `brand`, `unit_cost`, `unit_price` et `loaded_at`. Cette dimension permet d'analyser les ventes par catégorie, sous-catégorie, marque et produit.

- **dim_customer** : décrit les clients. Elle contient `customer_key` comme clé de substitution et `customer_id` comme clé naturelle. Les autres colonnes retenues sont `full_name`, `first_name`, `last_name`, `email_domain`, `city`, `province`, `loyalty_segment`, `join_date`, `effective_from`, `effective_to`, `is_current` et `loaded_at`. Elle permet d'analyser les ventes selon la localisation et le segment de fidélité des clients.

- **dim_store** : décrit les magasins. Elle contient `store_key` comme clé de substitution et `store_id` comme clé naturelle. Les autres colonnes retenues sont `store_name`, `city`, `region`, `province`, `store_type` et `loaded_at`. Elle est essentielle pour répondre à la question du CEO, car elle permet d'agréger les ventes par région.

- **dim_date** : décrit le calendrier d'analyse. Elle conserve `date_key` comme clé de jointure, car les faits référencent directement la date de vente. Les autres colonnes retenues sont `year`, `quarter`, `month`, `month_name`, `week_iso`, `day_of_week`, `day_name`, `is_weekend` et `loaded_at`. Cette dimension permet d'analyser les ventes par trimestre, mois, semaine ou jour.

- **dim_channel** : décrit les canaux de vente. Elle contient `channel_key` comme clé de substitution et `channel_id` comme clé naturelle. Les autres colonnes retenues sont `channel_name`, `channel_type` et `loaded_at`. Elle permet de comparer les ventes selon le canal utilisé, par exemple en ligne ou en magasin.

- **Mesures** :
 - `quantity` (additive) : correspond à la quantité de produits commandé par le client
 - `net_price` (additive) : correspond au prix unitaire net après remise
 | unit_price | net_price | discount_pct |
|-----------:|----------:|-------------:|
| 138.02     | 124.22    | 0.1          |
| 35.95      | 35.95     | 0.0          |
| 163.97     | 163.97    | 0.0          |
| 113.8      | 108.11    | 0.05         |
| 15.19      | 13.67     | 0.1          |
 -  `line_total` (additive): est le montant total de la commande qui est obtenu à partir de la formule  `quantity * net_price`
 -  `discount_pct` (non-additive -> moyenne pondérée): cette mesure ne doit pas être additionné entre les lignes, car le pour centage n'est pas une mesure additive. Pour analyser les remises à un niveau agrégé, il faudrait utiliser une moyenne pondérée, par exemple pondérée par `line_total` ou par `quantity`.

### Comment générer ce diagramme avec votre assistant IA

Collez un prompt comme celui-ci dans Copilot Chat :

> *« Génère un diagramme Mermaid `erDiagram` pour mon étoile NexaMart.
> Au centre : `FACT_SALES` au grain « une ligne de commande »
> (`order_number` + `sale_line_id`), avec les mesures `quantity`, `net_price`,
> `line_total`, `discount_pct`. Cinq dimensions reliées par FK :
> `dim_date`, `dim_product`, `dim_store`, `dim_customer`, `dim_channel`.
> Inclus le bloc dans un fichier Markdown. »*

## SQL preuve

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


|    category     | region  | quarter | total_revenue | nb_lignes |
|-----------------|---------|--------:|--------------:|----------:|
| Pet Supplies    | Québec  | 4       | 10982.23      | 28        |
| Pet Supplies    | Québec  | 2       | 8361.67       | 21        |
| Automotive      | Québec  | 4       | 7772.03       | 22        |
| Pet Supplies    | Québec  | 3       | 7753.10       | 18        |
| Beauty & Health | Québec  | 2       | 7478.66       | 27        |
| Toys & Games    | Québec  | 4       | 7374.96       | 25        |
| Pet Supplies    | Québec  | 1       | 7162.66       | 18        |
| Books & Media   | Québec  | 2       | 6536.74       | 23        |
| Pet Supplies    | Ontario | 3       | 6518.95       | 18        |
| Books & Media   | Québec  | 4       | 6137.86       | 20        |

**Vérifiaction du déclin en comparant  un trimestre avec le trimestre précédent**

```sql
WITH revenue_by_quarter AS (
    SELECT
        p.category,
        s.region,
        d.quarter,
        SUM(f.line_total) AS total_revenue
    FROM fact_sales f
    JOIN dim_product p ON f.product_key = p.product_key
    JOIN dim_store   s ON f.store_key   = s.store_key
    JOIN dim_date    d ON f.date_key    = d.date_key
    GROUP BY p.category, s.region, d.quarter
),
with_previous AS (
    SELECT
        category,
        region,
        quarter,
        total_revenue,
        LAG(total_revenue) OVER (
            PARTITION BY category, region
            ORDER BY quarter
        ) AS previous_revenue
    FROM revenue_by_quarter
)
SELECT
    category,
    region,
    quarter,
    previous_revenue,
    total_revenue,
    total_revenue - previous_revenue AS revenue_change
FROM with_previous
WHERE previous_revenue IS NOT NULL
ORDER BY revenue_change ASC
LIMIT 10;
```
|     category      |  region   | quarter | previous_revenue | total_revenue | revenue_change |
|-------------------|-----------|--------:|-----------------:|--------------:|---------------:|
| Automotive        | Outaouais | 3       | 4435.73          | 623.01        | -3812.72       |
| Automotive        | Ontario   | 2       | 4807.25          | 1009.37       | -3797.88       |
| Grocery           | Ontario   | 2       | 4069.97          | 1137.70       | -2932.27       |
| Pet Supplies      | Outaouais | 4       | 3092.63          | 503.72        | -2588.91       |
| Sports & Outdoors | Estrie    | 2       | 2234.77          | 260.11        | -1974.66       |
| Automotive        | BC        | 4       | 2990.59          | 1023.22       | -1967.37       |
| Toys & Games      | Ontario   | 2       | 3779.99          | 1896.05       | -1883.94       |
| Books & Media     | Ontario   | 4       | 4573.71          | 2752.69       | -1821.02       |
| Beauty & Health   | Ontario   | 4       | 5539.01          | 3729.82       | -1809.19       |
| Toys & Games      | Outaouais | 4       | 2700.90          | 979.88        | -1721.02       |

## Réponse exécutive

Les revenus les plus élevés sont concentrés au **Québec**, notamment pour **Pet Supplies**, **Automotive**, **Beauty & Health** et **Toys & Games**. L’Ontario apparaît aussi dans les meilleures combinaisons, mais de façon moins dominante.

Cependant les regions  **Outaouais**, **Ontario**, **Estrie**, et **BC** montrent des déclins de revenus dans  les trimestres Q3, Q2 et Q4 pour les catégories de produits **Pet Supplies**, **Automotive**, **grocery**, **Sports & Outdoors** et **Toys & Games**

## Validation
- **Vérification des contrôles d'intégrités**
```sql
SELECT
    SUM(CASE WHEN p.category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN s.region IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN d.quarter IS NULL THEN 1 ELSE 0 END) AS null_quarter
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_key
JOIN dim_store s ON f.store_key = s.store_key
JOIN dim_date d ON f.date_key = d.date_key;
```
| null_category | null_region | null_quarter |
|---------------|-------------|--------------|
| 0             | 0           | 0            |

Les colonnes de groupement `category`, `region` et  `quarter` ont été vérifiées afin d’éviter que des ventes soient regroupées dans des valeurs inconnues ou nulles.

**Validation du grain**
```sql
SELECT
    order_number,
    sale_line_id,
    COUNT(*) AS nb_lignes
FROM fact_sales
GROUP BY order_number, sale_line_id
HAVING COUNT(*) > 1;
```
Le grain a été validé en vérifiant que la combinaison ( `order_number`, `sale_line_id`) ne produit pas de doublons dans `fact_sales`. la requête n'a retournée aucune ligne
## Risques / limites
Manque d'informations directement liées à la table de fait pour expliquer les raisons du déclin
## Prochaine recommandation
**Recommandation :**  prioriser une analyse opérationnelle sur BC, Estrie et Outaouais, où les déclins observés sont les plus marqués. L’équipe devrait comparer les remises, les canaux de vente, les ruptures de stock et les retours pour les catégories Automotive, Pet Supplies et Sports & Outdoors. Un KPI de suivi pourrait être la variation du revenu trimestre sur trimestre, avec comme objectif de réduire les baisses les plus fortes au trimestre suivant.