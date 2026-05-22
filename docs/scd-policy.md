# Politique SCD — NexaMart

## Objectif

Cette politique indique quels changements de dimensions doivent être historisés
et lesquels peuvent être écrasés. La règle principale est business : si un
attribut influence un rapport historique ou une décision de performance, il
doit conserver son historique.

## dim_store

| Attribut | Type SCD | Justification business |
|---|---:|---|
| `region` | Type 2 | Les ventes doivent rester associées à la région du magasin au moment de la transaction. Une fusion régionale ne doit pas réécrire les rapports passés. |
| `province` | Type 2 | La province peut servir aux analyses géographiques et fiscales; un changement doit préserver les ventes historiques. |
| `store_name` | Type 1 | Une correction de nom ou de typo ne change pas l'analyse historique. |
| `store_id` | Aucun changement | Clé naturelle du magasin; elle identifie le magasin réel et ne doit pas être modifiée. |
| `store_key` | Clé substitut | Identifie chaque version du magasin dans le cas d'un SCD Type 2. |

## dim_customer

| Attribut | Type SCD | Justification business |
|---|---:|---|
| `loyalty_segment` | Type 2 | Le marketing doit pouvoir analyser les ventes selon le segment du client au moment de la transaction. |
| `city` | Type 2 | Un déménagement peut changer l'analyse géographique des ventes client. |
| `province` | Type 2 | La province peut influencer les analyses régionales et réglementaires. |
| `email` | Type 1 | Correction opérationnelle; l'ancienne adresse courriel n'a pas de valeur analytique pour les rapports. |
| `full_name` | Type 1 | Correction d'identité ou de typo; les ventes historiques n'ont pas besoin de conserver l'ancienne écriture du nom. |
| `customer_id` | Aucun changement | Clé naturelle du client; elle identifie le client réel. |
| `customer_key` | Clé substitut | Identifie chaque version du client dans le cas d'un SCD Type 2. |

## dim_product

| Attribut | Type SCD | Justification business |
|---|---:|---|
| `category` | Type 2 | Les ventes historiques doivent rester associées à la catégorie en vigueur au moment de la vente. |
| `subcategory` | Type 2 | Même logique que `category`; une reclassification ne doit pas réécrire l'historique. |
| `brand` | Type 2 | Si la marque est utilisée dans les rapports de performance, l'historique doit être conservé. |
| `product_name` | Type 1 | Correction de nom ou de typo, sans valeur analytique historique. |
| `unit_cost` | Type 1 ou fait séparé | Le coût utilisé pour calculer la marge doit être cohérent avec la vente; si les coûts changent souvent, ils doivent être historisés ou capturés au grain de la vente. |

## Règle de décision

- Type 1 : correction simple sans impact sur les rapports historiques.
- Type 2 : attribut utilisé pour analyser la performance au moment de l'événement.
- Type 3 : seulement si NexaMart veut comparer l'état actuel avec l'état précédent, sans historique complet.

## Application au scénario S03

Pour le changement `Outaouais` vers `Québec`, `dim_store.region` doit être en
Type 2. Sinon, les ventes et la marge historiques d'Outaouais sont réattribuées
à Québec, ce qui rend le rapport régional trompeur.