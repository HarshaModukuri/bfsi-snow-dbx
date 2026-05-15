# Databricks notebook source
# MAGIC %md
# MAGIC # Notebook 03: Silver Layer — Cleanse, Deduplicate, Enrich
# MAGIC 
# MAGIC This notebook reads from both Bronze sources (COPY INTO + Auto Loader),
# MAGIC deduplicates using **MERGE INTO**, validates data quality, and writes
# MAGIC to the Silver layer.
# MAGIC 
# MAGIC **Key patterns demonstrated:**
# MAGIC - UNION of multiple Bronze sources
# MAGIC - MERGE INTO for insert-only deduplication
# MAGIC - Data quality checks (null filtering, status validation)
# MAGIC - Derived columns for analytics

# COMMAND ----------

# MAGIC %sql
# MAGIC USE CATALOG bfsi_lakehouse;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Create Silver transactions table with enriched schema
# MAGIC CREATE TABLE IF NOT EXISTS bfsi_lakehouse.silver.transactions (
# MAGIC     transaction_id    STRING NOT NULL,
# MAGIC     account_id        STRING NOT NULL,
# MAGIC     transaction_date  TIMESTAMP,
# MAGIC     amount            DOUBLE,
# MAGIC     transaction_type  STRING,
# MAGIC     category          STRING,
# MAGIC     merchant_name     STRING,
# MAGIC     channel           STRING,
# MAGIC     status            STRING,
# MAGIC     reference_number  STRING,
# MAGIC     -- Derived columns
# MAGIC     transaction_day   DATE GENERATED ALWAYS AS (CAST(transaction_date AS DATE)),
# MAGIC     transaction_hour  INT,
# MAGIC     amount_bucket     STRING,
# MAGIC     is_high_value     BOOLEAN,
# MAGIC     -- Lineage
# MAGIC     _source           STRING,
# MAGIC     _ingested_at      TIMESTAMP,
# MAGIC     _processed_at     TIMESTAMP
# MAGIC );

# COMMAND ----------

# Read and union both Bronze sources
from pyspark.sql.functions import (
    col, lit, current_timestamp, hour, when
)

# Bronze: COPY INTO batch
df_batch = (
    spark.table("bfsi_lakehouse.bronze.transactions_batch")
    .withColumn("_source", lit("COPY_INTO"))
)

# Bronze: Auto Loader streaming
df_stream = (
    spark.table("bfsi_lakehouse.bronze.transactions_streaming")
    .withColumn("_source", lit("AUTO_LOADER"))
)

# Union both sources
df_combined = df_batch.unionByName(df_stream, allowMissingColumns=True)

print(f"Combined Bronze records: {df_combined.count()}")

# COMMAND ----------

# Apply Silver transformations
df_silver = (
    df_combined
    # Filter out failed transactions and nulls
    .filter(col("status") == "COMPLETED")
    .filter(col("transaction_id").isNotNull())
    .filter(col("account_id").isNotNull())
    .filter(col("amount").isNotNull())
    # Derive new columns
    .withColumn("transaction_hour", hour(col("transaction_date")))
    .withColumn("amount_bucket",
        when(col("amount") < 1000, "MICRO")
        .when(col("amount") < 10000, "SMALL")
        .when(col("amount") < 50000, "MEDIUM")
        .when(col("amount") < 100000, "LARGE")
        .otherwise("VERY_LARGE")
    )
    .withColumn("is_high_value", col("amount") >= 50000)
    .withColumn("_processed_at", current_timestamp())
    # Select final columns
    .select(
        "transaction_id", "account_id", "transaction_date",
        "amount", "transaction_type", "category", "merchant_name",
        "channel", "status", "reference_number",
        "transaction_hour", "amount_bucket", "is_high_value",
        "_source", "_ingested_at", "_processed_at"
    )
)

print(f"Silver records after filtering: {df_silver.count()}")

# COMMAND ----------

# Create temp view for MERGE
df_silver.createOrReplaceTempView("silver_staging")

# COMMAND ----------

# MAGIC %sql
# MAGIC -- MERGE INTO: Insert-only merge for deduplication
# MAGIC -- If transaction_id already exists in Silver, skip it
# MAGIC -- This prevents duplicates when both COPY INTO and Auto Loader
# MAGIC -- process the same files
# MAGIC 
# MAGIC MERGE INTO bfsi_lakehouse.silver.transactions AS target
# MAGIC USING silver_staging AS source
# MAGIC ON target.transaction_id = source.transaction_id
# MAGIC WHEN NOT MATCHED THEN INSERT (
# MAGIC     transaction_id, account_id, transaction_date, amount,
# MAGIC     transaction_type, category, merchant_name, channel,
# MAGIC     status, reference_number, transaction_hour,
# MAGIC     amount_bucket, is_high_value, _source, _ingested_at, _processed_at
# MAGIC ) VALUES (
# MAGIC     source.transaction_id, source.account_id, source.transaction_date,
# MAGIC     source.amount, source.transaction_type, source.category,
# MAGIC     source.merchant_name, source.channel, source.status,
# MAGIC     source.reference_number, source.transaction_hour,
# MAGIC     source.amount_bucket, source.is_high_value, source._source,
# MAGIC     source._ingested_at, source._processed_at
# MAGIC );

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Verify Silver layer
# MAGIC SELECT 
# MAGIC     COUNT(*) AS total_transactions,
# MAGIC     COUNT(DISTINCT account_id) AS unique_accounts,
# MAGIC     SUM(CASE WHEN is_high_value THEN 1 ELSE 0 END) AS high_value_count,
# MAGIC     ROUND(SUM(amount), 2) AS total_amount,
# MAGIC     MIN(transaction_date) AS earliest,
# MAGIC     MAX(transaction_date) AS latest
# MAGIC FROM bfsi_lakehouse.silver.transactions;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Distribution by amount bucket
# MAGIC SELECT amount_bucket, COUNT(*) AS txn_count, ROUND(SUM(amount), 2) AS total_amount
# MAGIC FROM bfsi_lakehouse.silver.transactions
# MAGIC GROUP BY amount_bucket
# MAGIC ORDER BY total_amount DESC;
