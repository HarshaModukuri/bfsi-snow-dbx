# Databricks notebook source
# MAGIC %md
# MAGIC # Notebook 02: Auto Loader — Streaming Ingestion
# MAGIC 
# MAGIC This notebook demonstrates **Auto Loader (cloudFiles)** for continuous/incremental
# MAGIC ingestion of new JSON files from a UC Volume into a Bronze Delta table.
# MAGIC 
# MAGIC **When to use Auto Loader:** New files arriving continuously, need schema evolution,
# MAGIC millions of files over time.
# MAGIC 
# MAGIC **Key difference from COPY INTO:** Auto Loader is streaming-based and handles
# MAGIC schema evolution natively. COPY INTO is a batch SQL command.

# COMMAND ----------

# MAGIC %sql
# MAGIC USE CATALOG bfsi_lakehouse;

# COMMAND ----------

source_path = "/Volumes/bfsi_lakehouse/bronze/raw_files/transactions/"
checkpoint_path = "/Volumes/bfsi_lakehouse/bronze/raw_files/_checkpoints/autoloader_txn"
target_table = "bfsi_lakehouse.bronze.transactions_streaming"

df_stream = (
    spark.readStream
    .format("cloudFiles")
    .option("cloudFiles.format", "json")
    .option("cloudFiles.schemaLocation", checkpoint_path + "/schema")
    .option("cloudFiles.inferColumnTypes", "true")
    .load(source_path)
)

# COMMAND ----------

from pyspark.sql.functions import current_timestamp, col

df_enriched = (
    df_stream
    .withColumn("_ingested_at", current_timestamp())
    .withColumn("_source_file", col("_metadata.file_path"))
)

# COMMAND ----------

(
    df_enriched.writeStream
    .format("delta")
    .option("checkpointLocation", checkpoint_path)
    .option("mergeSchema", "true")
    .trigger(availableNow=True)
    .toTable(target_table)
)

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Verify Auto Loader results
# MAGIC SELECT COUNT(*) AS total_rows,
# MAGIC        COUNT(DISTINCT _source_file) AS files_loaded,
# MAGIC        MIN(transaction_date) AS earliest_txn,
# MAGIC        MAX(transaction_date) AS latest_txn
# MAGIC FROM bfsi_lakehouse.bronze.transactions_streaming;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Compare: COPY INTO batch vs Auto Loader streaming
# MAGIC SELECT 'COPY INTO (batch)' AS method, COUNT(*) AS rows 
# MAGIC FROM bfsi_lakehouse.bronze.transactions_batch
# MAGIC UNION ALL
# MAGIC SELECT 'Auto Loader (stream)', COUNT(*) 
# MAGIC FROM bfsi_lakehouse.bronze.transactions_streaming;
