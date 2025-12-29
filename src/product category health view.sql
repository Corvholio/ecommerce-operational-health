-- =========================================================
-- View: vw_product_category_health
-- Purpose:
--   Prioritizing high-impact product categories 
--   by comparing customer volume with relative 
--   delivery performance.
--
-- Grain:
--   product_category_name
--
-- Notes:
--   - GMV is used as a proxy for customer value exposure,
--     not profitability.
--   - This view is designed for monitoring, not diagnosis.
-- =========================================================

CREATE VIEW vw_category_health AS
WITH order_item_enriched AS (
  SELECT
    oi.order_id,
    oi.product_id,
    COALESCE(p.product_category_name,"unknown") AS product_category_name,
    o.order_status,
    CASE WHEN o.order_status = 'delivered' THEN 1 ELSE 0 END AS is_delivered,
    CASE
      WHEN o.order_status = 'delivered'
       AND o.order_delivered_customer_date <= o.order_estimated_delivery_date
      THEN 1 ELSE 0
    END AS is_on_time,
    (oi.price + oi.freight_value) AS item_gmv
  FROM order_items oi
  JOIN orders o
    ON o.order_id = oi.order_id
  LEFT JOIN products p
    ON p.product_id = oi.product_id
),

category_order_rollup AS (
	SELECT
		product_category_name,
		order_id,
		SUM(item_gmv) AS category_gmv_in_order,
		MAX(is_delivered) AS is_delivered,
		MAX(is_on_time) AS is_on_time
	FROM order_item_enriched
	GROUP BY product_category_name, order_id
),

order_reviews_agg AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM order_reviews
    GROUP BY order_id
),

category_order_with_reviews AS (
    SELECT
        cr.product_category_name,
        cr.order_id,
        cr.category_gmv_in_order,
        cr.is_delivered,
        cr.is_on_time,
        ra.avg_review_score
    FROM category_order_rollup cr
    LEFT JOIN order_reviews_agg ra ON cr.order_id = ra.order_id
),

category_health AS (
    SELECT
        cor.product_category_name,
        COUNT(DISTINCT cor.order_id) AS total_orders,
        SUM(cor.category_gmv_in_order) AS total_gmv,
        SUM(cor.category_gmv_in_order)* 1.0/NULLIF(COUNT(DISTINCT cor.order_id),0) AS avg_order_value,
        AVG(CASE WHEN cor.is_delivered=1 THEN cor.is_on_time END) * 100 AS on_time_delivery_rate_pct,
        AVG(cor.avg_review_score) AS avg_review_score
    FROM category_order_with_reviews cor
    GROUP BY product_category_name
)
SELECT
  ch.product_category_name,
  ch.total_orders,
  ch.total_gmv,
  ch.avg_order_value,
  ch.on_time_delivery_rate_pct,
  ch.avg_review_score
FROM category_health ch