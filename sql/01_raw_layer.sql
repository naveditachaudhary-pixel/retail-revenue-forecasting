-- 01 · Raw layer (dataset: retro_raww)
-- Sales arrive as a CSV in Cloud Storage. They're read in place as an external table,
-- copied into a native table, and then into a date-partitioned table so queries that
-- filter by date only scan the days they need.

CREATE EXTERNAL TABLE `retro_raww.sales_external`
OPTIONS (
  format = "CSV",
  uris = ["gs://retro-retail-raw-navedita00/Sales_Data_Large.csv"]
);

CREATE TABLE `retro_raww.sales_native` (
  transaction_id INT64,
  date DATE,
  category STRING,
  product STRING,
  country STRING,
  revenue FLOAT64,
  quantity INT64
);

CREATE TABLE `retro_raww.sales_partitioned` (
  transaction_id INT64,
  date DATE,
  category STRING,
  product STRING,
  country STRING,
  revenue FLOAT64,
  quantity INT64
)
PARTITION BY date;

-- Raw customer records, as exported from the source system (messy on purpose).
CREATE TABLE `retro_raww.customers_raww` (
  customer_id INT64,
  full_name STRING,
  state STRING,
  email STRING,
  phone STRING
);
