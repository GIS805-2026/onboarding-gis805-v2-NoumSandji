# Schema v2 -- NexaMart S04

Ce schema documente le modele apres la seance S04. Il ajoute la dimension junk `dim_order_profile` et conserve `order_number` dans `fact_sales` comme dimension degeneree.

## Diagramme ER

```mermaid
erDiagram
    fact_sales {
        string order_number
        int sale_line_id
        date date_key
        int customer_key
        int product_key
        int store_key
        int channel_key
        int order_profile_key
        date order_date
        string customer_id
        string product_id
        string store_id
        string channel_id
        int quantity
        decimal unit_price
        decimal discount_pct
        decimal net_price
        decimal line_total
        decimal gross_amount
        decimal margin_amount
        date loaded_at
    }

    dim_order_profile {
        int order_profile_key
        int is_gift_wrapped
        int is_express_shipping
        int is_loyalty_redeemed
        int is_promo_applied
        int is_employee_purchase
        int is_online_pickup
        int is_fragile
        int is_oversized
        string profile_name
        date loaded_at
    }

    dim_date {
        date date_key
        int year
        int quarter
        int month
        string month_name
        int week_iso
        int day_of_week
        string day_name
        boolean is_weekend
        date loaded_at
    }

    dim_customer {
        int customer_key
        string customer_id
        string full_name
        string email_domain
        string city
        string province
        string loyalty_segment
        date join_date
        date effective_from
        date effective_to
        boolean is_current
        date loaded_at
    }

    dim_product {
        int product_key
        string product_id
        string product_name
        string category
        string subcategory
        string brand
        decimal unit_cost
        decimal unit_price
        date loaded_at
    }

    dim_store {
        int store_key
        string store_id
        string store_name
        string city
        string region
        string province
        string store_type
        date loaded_at
    }

    dim_channel {
        int channel_key
        string channel_id
        string channel_name
        string channel_type
        date loaded_at
    }

    dim_date ||--o{ fact_sales : "date_key"
    dim_customer ||--o{ fact_sales : "customer_key"
    dim_product ||--o{ fact_sales : "product_key"
    dim_store ||--o{ fact_sales : "store_key"
    dim_channel ||--o{ fact_sales : "channel_key"
    dim_order_profile ||--o{ fact_sales : "order_profile_key"
```

## Decisions de modelisation

- Le grain de `fact_sales` reste une ligne de commande, identifiee par `(order_number, sale_line_id)`.
- `order_number` est une dimension degeneree : il reste directement dans `fact_sales`, car il n'a pas d'attributs descriptifs propres.
- `dim_order_profile` est une junk dimension : elle regroupe les 8 drapeaux operationnels de commande.
- Les 8 drapeaux ne sont pas stockes directement dans `fact_sales`.
- `fact_sales` reference la junk dimension avec `order_profile_key`.
- `profile_name` rend les combinaisons de flags lisibles pour les operations, par exemple `standard_order` ou `gift_wrapped + loyalty_redeemed`.

## Grain des tables S04

| Table | Grain | Cle principale / identifiant |
|---|---|---|
| `fact_sales` | Une ligne de commande | `(order_number, sale_line_id)` |
| `dim_order_profile` | Une combinaison distincte des 8 flags | `order_profile_key` |
| `dim_product` | Un produit | `product_key` |
| `dim_customer` | Un client | `customer_key` |
| `dim_store` | Un magasin | `store_key` |
| `dim_channel` | Un canal de vente | `channel_key` |
| `dim_date` | Une date calendrier | `date_key` |

## Validation S04

Les controles suivants ont ete executes apres ajout de `order_profile_key` dans `fact_sales` :

| Controle | Resultat |
|---|---:|
| Lignes dans `fact_sales` | 2 147 |
| Commandes distinctes dans `fact_sales` | 667 |
| Profils utilises dans `fact_sales` | 95 |
| `order_profile_key` nulles | 0 |
| Profils observes dans `dim_order_profile` | 97 |
| Doublons au grain `(order_number, sale_line_id)` | 0 |
| Cles `order_profile_key` orphelines | 0 |

## Lecture du modele

Le modele permet deux analyses S04 :

- profils operationnels : `fact_sales` rejoint `dim_order_profile` par `order_profile_key` ;
- analyse de panier : `fact_sales` est auto-jointe sur `order_number` pour trouver les produits achetes ensemble.
