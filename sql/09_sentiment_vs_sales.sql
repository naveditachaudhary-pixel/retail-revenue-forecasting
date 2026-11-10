-- 09 · Sentiment, top complaint and sales by product
-- The reviews and the sales data name products differently: reviews say "Screen" where sales say
-- "Monitor", and "Mouse" has reviews but no sales at all. The mapping below handles the first;
-- the second is reported as a data-quality issue rather than hidden.

WITH name_map AS (
  SELECT 'screen' AS review_name, 'monitor' AS sales_name
),
sales AS (
  SELECT LOWER(TRIM(product)) AS key, ROUND(SUM(revenue)) AS revenue, SUM(quantity) AS units
  FROM `retro_raww.sales_partitioned`
  GROUP BY key
),
reviews AS (
  SELECT r.*, COALESCE(m.sales_name, LOWER(TRIM(r.product))) AS key
  FROM `retro_raww.review_sentiment` r
  LEFT JOIN name_map m ON m.review_name = LOWER(TRIM(r.product))
),
complaints AS (
  SELECT key, word, COUNT(*) AS n
  FROM reviews r, UNNEST(REGEXP_EXTRACT_ALL(LOWER(r.review_text), r'[a-z]+')) AS word
  WHERE r.sentiment = 'negative' AND word IN ('bad','broken','slow','terrible','worst')
  GROUP BY key, word
),
top_complaint AS (
  SELECT key, ARRAY_AGG(word ORDER BY n DESC LIMIT 1)[OFFSET(0)] AS top_complaint
  FROM complaints GROUP BY key
)
SELECT ANY_VALUE(r.product) AS product,
       COUNT(*) AS reviews,
       COUNTIF(r.sentiment = 'positive') AS positive,
       COUNTIF(r.sentiment = 'negative') AS negative,
       ROUND(100 * COUNTIF(r.sentiment = 'positive') / COUNT(*), 1) AS pct_positive,
       ANY_VALUE(t.top_complaint) AS top_complaint,
       ANY_VALUE(s.revenue) AS revenue,   -- NULL means the product isn't in the sales data
       ANY_VALUE(s.units) AS units
FROM reviews r
LEFT JOIN sales s USING (key)
LEFT JOIN top_complaint t USING (key)
GROUP BY r.key
ORDER BY pct_positive;
