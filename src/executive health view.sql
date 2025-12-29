-- =========================================================
-- View: vw_executive_commerce_health
-- Purpose:
--   Provide system-level monitoring of e-commerce health
--   including order volume, fulfillment performance, and
--   customer sentiment over time.
--
-- Grain:
--   Month
--
-- Notes:
--   - GMV is used as a proxy for customer value exposure,
--     not profitability.
--   - This view is designed for monitoring, not diagnosis.
-- =========================================================

CREATE VIEW vw_executive_commerce_health AS
WITH

valid_orders AS (
	SELECT DISTINCT
		o.order_id,
		o.order_status,
		o.order_purchase_timestamp,
		o.order_delivered_customer_date,
		o.order_estimated_delivery_date
	FROM orders o
	INNER JOIN order_items oi ON o.order_id = oi.order_id
	WHERE oi.order_id IS NOT NULL
),

order_gmv AS (
	SELECT
		oi.order_id,
		sum(oi.price + oi.freight_value) AS gmv
	FROM order_items oi
	GROUP BY oi.order_id
),

order_reviews_agg AS (
	SELECT
		r.order_id,
		AVG(r.review_score) AS avg_review_score
	FROM order_reviews r
	GROUP BY r.order_id
),

order_level AS (
	SELECT 
		vo.order_id,
		strftime('%Y-%m', vo.order_purchase_timestamp) AS order_month,
		og.gmv,
		CASE
			WHEN vo.order_status = 'delivered' THEN 1
			ELSE 0
		END AS is_delivered,
		CASE
			WHEN vo.order_status = 'delivered'
				AND vo.order_delivered_customer_date <= vo.order_estimated_delivery_date
			THEN 1
			ELSE 0
		END AS is_on_time,
		orv.avg_review_score
	FROM valid_orders vo
	LEFT JOIN order_gmv og ON vo.order_id = og.order_id
	LEFT JOIN order_reviews_agg orv ON vo.order_id = orv.order_id
),

monthly_health AS (
	SELECT
		order_month,
		COUNT(order_id) AS valid_order_count,
		SUM(coalesce(gmv,0)) AS total_gmv,
		AVG(coalesce(gmv,0)) AS avg_order_value,
		ROUND(
			AVG(is_delivered) *100,
			2
		) AS order_completion_rate_pct,
		ROUND(
			AVG(
				CASE
					WHEN is_delivered=1 THEN is_on_time
				END
			)* 100,
			2
		) AS on_time_delivery_rate_pct,
		ROUND(AVG(avg_review_score),2) AS avg_review_score
	FROM order_level
	GROUP BY order_month
	ORDER BY order_month
)
	
SELECT
  order_month,

  valid_order_count,
  valid_order_count - LAG(valid_order_count) OVER (ORDER BY order_month) AS valid_order_count_delta,

  total_gmv,
  total_gmv - LAG(total_gmv) OVER (ORDER BY order_month) AS total_gmv_delta,

  avg_order_value,
  avg_order_value - LAG(avg_order_value) OVER (ORDER BY order_month) AS avg_order_value_delta,

  order_completion_rate_pct,
  order_completion_rate_pct - LAG(order_completion_rate_pct) OVER (ORDER BY order_month) AS completion_rate_delta,

  on_time_delivery_rate_pct,
  on_time_delivery_rate_pct - LAG(on_time_delivery_rate_pct) OVER (ORDER BY order_month) AS on_time_rate_delta,

  avg_review_score,
  avg_review_score - LAG(avg_review_score) OVER (ORDER BY order_month) AS review_score_delta
FROM monthly_health
ORDER BY order_month
	
	