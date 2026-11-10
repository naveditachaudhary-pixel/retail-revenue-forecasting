-- 02 · Cleaning customer records
-- A view, so the cleaned version is always up to date with the raw table.

CREATE VIEW `retro_raww.view_customers_clean` AS
SELECT
  customer_id,

  -- 1) Clean name
  INITCAP(TRIM(full_name)) AS clean_name,

  -- 2) Standardize state
  CASE
    WHEN UPPER(TRIM(state)) LIKE 'OH%' THEN 'OH'
    WHEN UPPER(TRIM(state)) LIKE 'KY%' THEN 'KY'
    WHEN UPPER(TRIM(state)) LIKE 'IN%' THEN 'IN'
    ELSE 'UNKNOWN'
  END AS clean_state,

  -- 3) Clean email
  LOWER(
    COALESCE(NULLIF(TRIM(email), ''), 'unknown@noemail.com')
  ) AS clean_email

FROM `retro_raww.customers_raww`

-- 4) De-dupe: keep 1 row per customer_id
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY customer_id
  ORDER BY customer_id DESC
) = 1;
