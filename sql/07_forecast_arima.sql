-- 07 · Final model on all the data, what it learned, and a 90-day forecast

CREATE OR REPLACE MODEL `retro_raww.model_revenue_arima`
OPTIONS (
  model_type = 'ARIMA_PLUS',
  time_series_timestamp_col = 'date',
  time_series_data_col = 'total_revenue',
  data_frequency = 'DAILY',
  holiday_region = 'US',
  auto_arima = TRUE
) AS
SELECT date, total_revenue FROM `retro_raww.view_training_data`;

-- Which ARIMA settings were chosen, and whether it found weekly patterns, holidays and spikes
SELECT * FROM ML.ARIMA_EVALUATE(MODEL `retro_raww.model_revenue_arima`);

-- The next 90 days, with a 90% prediction range
SELECT DATE(forecast_timestamp) AS date,
       ROUND(forecast_value) AS forecast,
       ROUND(prediction_interval_lower_bound) AS low,
       ROUND(prediction_interval_upper_bound) AS high
FROM ML.FORECAST(MODEL `retro_raww.model_revenue_arima`, STRUCT(90 AS horizon, 0.9 AS confidence_level))
ORDER BY date;
