-- 05 · Daily revenue, the series the forecasting models learn from

CREATE VIEW `retro_raww.view_training_data` AS
SELECT
  date,
  SUM(revenue) AS total_revenue
FROM `retro_raww.sales_partitioned`
GROUP BY date;
