-- Databricks notebook source
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state,
    oi.order_item_id,
    oi.price,
    oi.freight_value

FROM workspace.ecommerce.silver_orders o

INNER JOIN workspace.ecommerce.silver_customers c
    ON o.customer_id = c.customer_id

INNER JOIN workspace.ecommerce.silver_order_items oi
    ON o.order_id = oi.order_id

LIMIT 10;

-- COMMAND ----------

SELECT SUM(oi.price) AS total_revenue
FROM workspace.ecommerce.silver_order_items oi
INNER JOIN workspace.ecommerce.silver_orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- COMMAND ----------

SELECT DATE_TRUNC('MONTH', o.order_purchase_timestamp) AS sales_month,
SUM(oi.price) AS monthly_revenue
FROM workspace.ecommerce.silver_order_items oi
INNER JOIN workspace.ecommerce.silver_orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY sales_month
ORDER BY sales_month ASC;

-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.ecommerce.gold_monthly_revenue
USING DELTA
AS

SELECT
    DATE_TRUNC('MONTH', o.order_purchase_timestamp) AS sales_month,
    SUM(oi.price) AS monthly_revenue

FROM workspace.ecommerce.silver_order_items oi

INNER JOIN workspace.ecommerce.silver_orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'

GROUP BY sales_month;

-- COMMAND ----------

SELECT *
FROM workspace.ecommerce.gold_monthly_revenue
ORDER BY sales_month;

-- COMMAND ----------

SELECT c.customer_state, SUM(oi.price) AS state_revenue
FROM workspace.ecommerce.silver_orders o
INNER JOIN workspace.ecommerce.silver_customers c
    ON o.customer_id = c.customer_id
INNER JOIN workspace.ecommerce.silver_order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY state_revenue DESC;


-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.ecommerce.gold_state_revenue
USING DELTA
AS

SELECT
    c.customer_state,
    SUM(oi.price) AS state_revenue

FROM workspace.ecommerce.silver_orders o

INNER JOIN workspace.ecommerce.silver_customers c
    ON o.customer_id = c.customer_id

INNER JOIN workspace.ecommerce.silver_order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY c.customer_state;

-- COMMAND ----------

SELECT *
FROM workspace.ecommerce.gold_state_revenue
ORDER BY state_revenue DESC;

-- COMMAND ----------

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_spent

FROM workspace.ecommerce.silver_orders o

INNER JOIN workspace.ecommerce.silver_customers c
    ON o.customer_id = c.customer_id

INNER JOIN workspace.ecommerce.silver_order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY c.customer_unique_id

ORDER BY total_spent DESC

LIMIT 10;

-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.ecommerce.gold_customer_spending
USING DELTA
AS

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_spent

FROM workspace.ecommerce.silver_orders o

INNER JOIN workspace.ecommerce.silver_customers c
    ON o.customer_id = c.customer_id

INNER JOIN workspace.ecommerce.silver_order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'

GROUP BY c.customer_unique_id;

-- COMMAND ----------

SELECT *
FROM workspace.ecommerce.gold_customer_spending
ORDER BY total_spent DESC
LIMIT 10;

-- COMMAND ----------

SELECT
    SUM(oi.price) AS total_revenue,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM workspace.ecommerce.silver_orders o

INNER JOIN workspace.ecommerce.silver_order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered';

-- COMMAND ----------

CREATE OR REPLACE TABLE workspace.ecommerce.gold_sales_kpis
USING DELTA
AS

SELECT
    SUM(oi.price) AS total_revenue,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(
        SUM(oi.price) / COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM workspace.ecommerce.silver_orders o

INNER JOIN workspace.ecommerce.silver_order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered';

-- COMMAND ----------

SELECT *
FROM workspace.ecommerce.gold_sales_kpis;

-- COMMAND ----------

SELECT
    (SELECT total_revenue
     FROM workspace.ecommerce.gold_sales_kpis)
        AS kpi_revenue,

    (SELECT SUM(monthly_revenue)
     FROM workspace.ecommerce.gold_monthly_revenue)
        AS monthly_revenue_total,

    (SELECT SUM(state_revenue)
     FROM workspace.ecommerce.gold_state_revenue)
        AS state_revenue_total;

-- COMMAND ----------

ALTER TABLE workspace.ecommerce.gold_customer_spending
ADD COLUMNS (customer_label STRING);

-- COMMAND ----------

UPDATE workspace.ecommerce.gold_customer_spending
SET customer_label = CONCAT(
    'Customer ',
    SUBSTRING(customer_unique_id, 1, 6)
);

-- COMMAND ----------

SELECT customer_label, total_spent
FROM workspace.ecommerce.gold_customer_spending
ORDER BY total_spent DESC
LIMIT 10;
