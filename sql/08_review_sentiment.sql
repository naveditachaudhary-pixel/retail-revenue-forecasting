-- 08 · Review sentiment
-- The 1,000 reviews are generated from two templates:
--   "I <word> this <product>. It is <word>."        (positive words)
--   "This <product> is <word>. It arrived <word>."  (negative words)
-- so a word list that covers every word they use classifies each review exactly.
-- BigQuery's AI text models need billing; this rule-based approach runs in the free sandbox.

CREATE OR REPLACE TABLE `retro_raww.review_sentiment` AS
WITH lexicon AS (
  SELECT word, 1 AS polarity FROM UNNEST(['amazing','best','fast','great','love']) AS word
  UNION ALL
  SELECT word, -1 FROM UNNEST(['bad','broken','slow','terrible','worst']) AS word
),
scored AS (
  SELECT r.review_id, SUM(l.polarity) AS score
  FROM `retro_raww.reviews_raw` r,
       UNNEST(REGEXP_EXTRACT_ALL(LOWER(r.review_text), r'[a-z]+')) AS word
  JOIN lexicon l USING (word)
  GROUP BY r.review_id
)
SELECT r.review_id, r.product, r.review_text, COALESCE(s.score, 0) AS score,
       CASE WHEN COALESCE(s.score, 0) > 0 THEN 'positive'
            WHEN COALESCE(s.score, 0) < 0 THEN 'negative' ELSE 'neutral' END AS sentiment
FROM `retro_raww.reviews_raw` r
LEFT JOIN scored s USING (review_id);

-- Check: every review classified (result: 521 positive, 479 negative, 0 neutral)
SELECT sentiment, COUNT(*) AS reviews FROM `retro_raww.review_sentiment` GROUP BY sentiment;
