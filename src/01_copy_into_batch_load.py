# Databricks notebook source
# MAGIC %md
# MAGIC # Notebook 01: COPY INTO — Batch Load Historical Transactions
# MAGIC 
# MAGIC This notebook demonstrates **COPY INTO** for idempotent batch ingestion
# MAGIC of JSON files from a Unity Catalog Volume into a Bronze Delta table.
# MAGIC 
# MAGIC **When to use COPY INTO:** One-time or scheduled batch loads from files.
# MAGIC Files are tracked so re-running won't duplicate data.

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Create catalog and schema (if not exists)
# MAGIC CREATE CATALOG IF NOT EXISTS bfsi_lakehouse;
# MAGIC USE CATALOG bfsi_lakehouse;
# MAGIC CREATE SCHEMA IF NOT EXISTS bronze;
# MAGIC CREATE SCHEMA IF NOT EXISTS silver;
# MAGIC CREATE SCHEMA IF NOT EXISTS gold;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Create a Volume to store raw JSON files
# MAGIC CREATE VOLUME IF NOT EXISTS bfsi_lakehouse.bronze.raw_files;

# COMMAND ----------

# MAGIC %md
# MAGIC ### Upload JSON files
# MAGIC 
# MAGIC Before running the next cell, upload the JSON files from `data/` folder
# MAGIC into the Volume at `/Volumes/bfsi_lakehouse/bronze/raw_files/transactions/`
# MAGIC 
# MAGIC You can do this via:
# MAGIC - Databricks UI: Catalog → Volumes → Upload
# MAGIC - Or use `databricks fs cp` from the CLI

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Verify files are in the Volume
# MAGIC LIST '/Volumes/bfsi_lakehouse/bronze/raw_files/transactions/';

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Create Bronze table for batch-loaded transactions
# MAGIC CREATE TABLE IF NOT EXISTS bfsi_lakehouse.bronze.transactions_batch (
# MAGIC     transaction_id    STRING,
# MAGIC     account_id        STRING,
# MAGIC     transaction_date  TIMESTAMP,
# MAGIC     amount            DOUBLE,
# MAGIC     transaction_type  STRING,
# MAGIC     category          STRING,
# MAGIC     merchant_name     STRING,
# MAGIC     channel           STRING,
# MAGIC     status            STRING,
# MAGIC     reference_number  STRING,
# MAGIC     _ingested_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
# MAGIC     _source_file      STRING
# MAGIC );

# COMMAND ----------

# MAGIC %sql
# MAGIC -- COPY INTO: Idempotent batch load
# MAGIC -- Re-running this will NOT re-load already-processed files
# MAGIC 
# MAGIC COPY INTO bfsi_lakehouse.bronze.transactions_batch
# MAGIC FROM (
# MAGIC     SELECT 
# MAGIC         *,
# MAGIC         current_timestamp() AS _ingested_at,
# MAGIC         _metadata.file_path AS _source_file
# MAGIC     FROM '/Volumes/bfsi_lakehouse/bronze/raw_files/transactions/'
# MAGIC )
# MAGIC FILEFORMAT = JSON
# MAGIC FORMAT_OPTIONS ('multiLine' = 'false')
# MAGIC COPY_OPTIONS ('mergeSchema' = 'true');

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Verify the load
# MAGIC SELECT COUNT(*) AS total_rows, 
# MAGIC        COUNT(DISTINCT _source_file) AS files_loaded,
# MAGIC        MIN(transaction_date) AS earliest_txn,
# MAGIC        MAX(transaction_date) AS latest_txn
# MAGIC FROM bfsi_lakehouse.bronze.transactions_batch;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Show sample data
# MAGIC SELECT * FROM bfsi_lakehouse.bronze.transactions_batch LIMIT 10;
