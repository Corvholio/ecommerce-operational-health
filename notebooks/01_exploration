# Data Exploration Notes

## Dataset Overview
This project uses the Olist e-commerce dataset, containing order,
item, product, delivery, and review data.

## Initial Observations
- Orders and order items are not guaranteed 1:1
- Product category names contain nulls, handled as "Unknown"
- Delivery performance variance is narrow (≈90–93%)

## Key Design Implication
Because delivery performance varies narrowly, absolute thresholds
are less meaningful than relative comparisons.

This directly informed the use of ranking and impact-weighted views
in downstream dashboards.
