-- 04 · Warehouse (dataset: retro_warehouse)
-- A star schema for reporting: one fact table of sales, surrounded by dimensions.

CREATE TABLE `retro_warehouse.dim_date` (
  date_id DATE,
  full_date DATE,
  month INT64,
  year INT64,
  quarter INT64
);

CREATE TABLE `retro_warehouse.dim_category` (
  category_id INT64,
  category_name STRING
);

CREATE TABLE `retro_warehouse.dim_product` (
  product_id INT64,
  product_name STRING,
  price FLOAT64,
  category_id INT64      -- → dim_category.category_id
);

CREATE TABLE `retro_warehouse.dim_store` (
  store_id INT64,
  store_name STRING,
  region STRING
);

CREATE TABLE `retro_warehouse.fact_sales` (
  transaction_id INT64,
  date_id DATE,          -- → dim_date.date_id
  store_id INT64,        -- → dim_store.store_id
  product_id INT64,      -- → dim_product.product_id
  quantity_sold INT64,
  revenue FLOAT64
);
