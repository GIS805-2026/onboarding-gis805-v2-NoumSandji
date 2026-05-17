# Board Brief -- S02 : Première étoile

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

