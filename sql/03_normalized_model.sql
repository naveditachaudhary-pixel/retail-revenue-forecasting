-- 03 · Normalized model (dataset: retro_normalized)
-- Customers, products and orders in separate tables, so each fact is stored once.

CREATE TABLE `retro_normalized.customers` (
  customer_id INT64,
  customer_name STRING,
  customer_address STRING,
  customer_city STRING
);

CREATE TABLE `retro_normalized.products` (
  product_id INT64,
  product_name STRING,
  product_price FLOAT64
);

CREATE TABLE `retro_normalized.orders` (
  order_id INT64,
  customer_id INT64,     -- → customers.customer_id
  product_id INT64,      -- → products.product_id
  quantity_ordered INT64,
  order_date DATE
);
