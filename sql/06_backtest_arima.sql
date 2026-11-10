-- 06 · Is the forecast any good? Hold out the last 60 days, train on the rest,
-- then compare the forecast with what actually happened, and with a simple baseline
-- that guesses "same as the average of the last 4 weeks".

CREATE OR REPLACE MODEL `retro_raww.model_revenue_arima_test`
OPTIONS (
  model_type = 'ARIMA_PLUS',
  time_series_timestamp_col = 'date',
  time_series_data_col = 'total_revenue',
  data_frequency = 'DAILY',
  holiday_region = 'US',
  auto_arima = TRUE
) AS
SELECT date, total_revenue
FROM `retro_raww.view_training_data`
WHERE date <= DATE_SUB((SELECT MAX(date) FROM `retro_raww.view_training_data`), INTERVAL 60 DAY);

WITH cutoff AS (
  SELECT DATE_SUB(MAX(date), INTERVAL 60 DAY) AS d FROM `retro_raww.view_training_data`
),
actual AS (
  SELECT v.date, v.total_revenue FROM `retro_raww.view_training_data` v, cutoff WHERE v.date > cutoff.d
),
forecast AS (
  SELECT DATE(forecast_timestamp) AS date, forecast_value,
         prediction_interval_lower_bound AS low, prediction_interval_upper_bound AS high
  FROM ML.FORECAST(MODEL `retro_raww.model_revenue_arima_test`, STRUCT(60 AS horizon, 0.9 AS confidence_level))
),
baseline AS (
  SELECT AVG(v.total_revenue) AS guess FROM `retro_raww.view_training_data` v, cutoff
  WHERE v.date BETWEEN DATE_SUB(cutoff.d, INTERVAL 27 DAY) AND cutoff.d
)
SELECT
  COUNT(*) AS test_days,
  ROUND(AVG(a.total_revenue)) AS avg_daily_revenue,
  ROUND(AVG(ABS(f.forecast_value - a.total_revenue))) AS arima_error,
  ROUND(100 * AVG(ABS(f.forecast_value - a.total_revenue) / NULLIF(a.total_revenue, 0)), 1) AS arima_error_pct,
  ROUND(AVG(ABS(b.guess - a.total_revenue))) AS baseline_error,
  ROUND(100 * AVG(ABS(b.guess - a.total_revenue) / NULLIF(a.total_revenue, 0)), 1) AS baseline_error_pct,
  ROUND(100 * COUNTIF(a.total_revenue BETWEEN f.low AND f.high) / COUNT(*), 1) AS pct_inside_90pct_range
FROM actual a JOIN forecast f USING (date) CROSS JOIN baseline b;
