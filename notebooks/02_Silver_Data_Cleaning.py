# Databricks notebook source
orders_df = spark.table(
    "workspace.ecommerce.bronze_orders"
)

display(orders_df)

# COMMAND ----------

from pyspark.sql.functions import col, sum

orders_df.select([
    sum(col(c).isNull().cast("int")).alias(c)
    for c in orders_df.columns
]).show()

# COMMAND ----------

orders_df.groupBy("order_id").count().filter("count > 1").show()

# COMMAND ----------

from pyspark.sql.functions import to_timestamp

silver_orders_df = orders_df.withColumn(
    "order_purchase_timestamp",
    to_timestamp("order_purchase_timestamp")
)

# COMMAND ----------

silver_orders_df.printSchema()

# COMMAND ----------

silver_orders_df = (
    silver_orders_df
    .withColumn(
        "order_approved_at",
        to_timestamp("order_approved_at")
    )
    .withColumn(
        "order_delivered_carrier_date",
        to_timestamp("order_delivered_carrier_date")
    )
    .withColumn(
        "order_delivered_customer_date",
        to_timestamp("order_delivered_customer_date")
    )
    .withColumn(
        "order_estimated_delivery_date",
        to_timestamp("order_estimated_delivery_date")
    )
)

# COMMAND ----------

silver_orders_df.printSchema()

# COMMAND ----------

silver_orders_df.write.format("delta").mode("overwrite").saveAsTable("workspace.ecommerce.silver_orders")

# COMMAND ----------

customers_df = spark.table(
    "workspace.ecommerce.bronze_customers"
)

display(customers_df)

# COMMAND ----------

customers_df.groupBy("customer_id").count().filter("count > 1").show()

# COMMAND ----------

from pyspark.sql.functions import col, sum

customers_df.select([
    sum(col(c).isNull().cast("int")).alias(c)
    for c in customers_df.columns
]).show()

# COMMAND ----------

silver_customers_df = customers_df

silver_customers_df.write.format("delta").mode("overwrite").saveAsTable("workspace.ecommerce.silver_customers")

# COMMAND ----------

order_items_df = spark.table(
    "workspace.ecommerce.bronze_order_items"
)

display(order_items_df)

# COMMAND ----------

order_items_df.groupBy("order_id", "order_item_id").count().filter("count > 1").show()

# COMMAND ----------

from pyspark.sql.functions import col, sum

order_items_df.select([
    sum(col(c).isNull().cast("int")).alias(c)
    for c in order_items_df.columns
]).show()

# COMMAND ----------

from pyspark.sql.functions import col

silver_order_items_df = (
    order_items_df
    .withColumn("price", col("price").cast("decimal(12,2)"))
    .withColumn("freight_value", col("freight_value").cast("decimal(12,2)"))
    .withColumn("order_item_id", col("order_item_id").cast("int"))
)

# COMMAND ----------

silver_order_items_df.printSchema()

# COMMAND ----------

from pyspark.sql.functions import to_timestamp

silver_order_items_df = silver_order_items_df.withColumn(
    "shipping_limit_date",
    to_timestamp("shipping_limit_date")
)

# COMMAND ----------

silver_order_items_df.printSchema()

# COMMAND ----------

from pyspark.sql.functions import col, sum

silver_order_items_df.select([
    sum(col(c).isNull().cast("int")).alias(c)
    for c in [
        "order_item_id",
        "price",
        "freight_value",
        "shipping_limit_date"
    ]
]).show()

# COMMAND ----------

silver_order_items_df.write.format("delta").mode("overwrite").saveAsTable("workspace.ecommerce.silver_order_items")
