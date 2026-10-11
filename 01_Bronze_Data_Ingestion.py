# Databricks notebook source
orders_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_ecommerce/olist_orders_dataset.csv",
    header=True,
    inferSchema=False
)

display(orders_df)

# COMMAND ----------

orders_df.write.format("delta").mode("overwrite").saveAsTable("workspace.ecommerce.bronze_orders")

# COMMAND ----------

customers_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_ecommerce/olist_customers_dataset.csv",
    header=True,
    inferSchema=False
)

display(customers_df)

# COMMAND ----------

customers_df.write.format("delta").mode("overwrite").saveAsTable("workspace.ecommerce.bronze_customers")

# COMMAND ----------

order_items_df = spark.read.csv(
    "/Volumes/workspace/ecommerce/raw_ecommerce/olist_order_items_dataset.csv",
    header=True,
    inferSchema=False
)

display(order_items_df)

# COMMAND ----------

order_items_df.write.format("delta") .mode("overwrite") .saveAsTable("workspace.ecommerce.bronze_order_items")

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT *
# MAGIC FROM workspace.ecommerce.bronze_orders;