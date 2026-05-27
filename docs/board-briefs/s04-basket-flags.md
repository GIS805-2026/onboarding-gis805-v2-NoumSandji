# S04 Board Brief -- Basket & Flags

## Question

Quels patterns de commande et quelles affinites de panier sont importants pour les operations NexaMart ?

## Constats cles

- Le profil `standard_order` domine le volume : 118 commandes, 374 lignes de commande et 87 055,52 $ de revenu.
- Le profil `loyalty_redeemed` arrive deuxieme : 66 commandes et 45 600,89 $ de revenu.
- Les profils `express_shipping`, `gift_wrapped` et `fragile` sont les prochains profils operationnels les plus frequents.
- La paire de categories la plus frequente est `Clothing + Sports & Outdoors`, avec 78 paniers.
- La paire de categories la plus forte en revenu dans le top est `Clothing + Pet Supplies`, avec 41 915,33 $.
- `Pet Supplies` apparait dans plusieurs associations a fort revenu, notamment avec `Clothing`, `Beauty & Health`, `Grocery` et `Electronics`.

## Evidence 1 -- Profils de commande

| Profil | Commandes | Lignes | Revenu | Moyenne par ligne |
|---|---:|---:|---:|---:|
| `standard_order` | 118 | 374 | 87 055,52 $ | 232,77 $ |
| `loyalty_redeemed` | 66 | 218 | 45 600,89 $ | 209,18 $ |
| `express_shipping` | 45 | 142 | 30 741,56 $ | 216,49 $ |
| `gift_wrapped` | 39 | 134 | 29 028,91 $ | 216,63 $ |
| `fragile` | 36 | 126 | 28 874,76 $ | 229,16 $ |

## Evidence 2 -- Paires de produits co-achetees

| Produit A | Produit B | Paniers ensemble | Revenu associe |
|---|---|---:|---:|
| Electronics Item 9 | Pet Supplies Item 10 | 7 | 3 790,31 $ |
| Clothing Item 8 | Pet Supplies Item 3 | 7 | 3 531,59 $ |
| Home & Garden Item 4 | Beauty & Health Item 7 | 7 | 2 560,12 $ |
| Home & Garden Item 3 | Sports & Outdoors Item 7 | 7 | 2 018,15 $ |
| Electronics Item 3 | Beauty & Health Item 10 | 7 | 1 770,95 $ |

## Evidence 3 -- Paires de categories

| Categorie A | Categorie B | Paniers ensemble | Revenu associe |
|---|---|---:|---:|
| Clothing | Sports & Outdoors | 78 | 24 498,95 $ |
| Clothing | Pet Supplies | 65 | 41 915,33 $ |
| Clothing | Grocery | 61 | 22 786,96 $ |
| Electronics | Sports & Outdoors | 60 | 15 276,54 $ |
| Electronics | Pet Supplies | 55 | 32 689,96 $ |

## Recommandation VP

Tester des recommandations croisees et des promotions autour de `Pet Supplies`, surtout avec `Clothing`, `Beauty & Health`, `Grocery` et `Electronics`. Cette categorie revient dans plusieurs paniers a fort revenu et peut servir de point d'ancrage pour des offres combinees.

## Decision de modelisation

- `order_number` reste dans `fact_sales` comme dimension degeneree.
- Les 8 drapeaux operationnels sont consolides dans `dim_order_profile`.
- `fact_sales` garde seulement `order_profile_key`, ce qui evite d'ajouter 8 colonnes de flags directement dans la table de faits.
- `profile_name` transforme les combinaisons techniques en profils lisibles pour les operations.

## Validation

| Controle | Resultat |
|---|---:|
| Lignes dans `fact_sales` | 2 147 |
| Commandes distinctes | 667 |
| Profils utilises | 95 |
| `order_profile_key` nulles | 0 |
| Profils observes dans `dim_order_profile` | 97 |
| Doublons au grain `(order_number, sale_line_id)` | 0 |
| Cles `order_profile_key` orphelines | 0 |
