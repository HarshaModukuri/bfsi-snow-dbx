# Databricks notebook source
# MAGIC %md
# MAGIC # Notebook 04: Gold Layer — Business Aggregates
# MAGIC 
# MAGIC Creates Gold layer objects for BI and analytics:
# MAGIC - **Daily transaction summary** (materialized view or table)
# MAGIC - **Customer spending profile** (aggregate table)
# MAGIC - **Channel analytics** (aggregate table)
# MAGIC 
# MAGIC **Gold layer pattern:** Pre-aggregated, optimized for fast queries.

# COMMAND ----------

# MAGIC %sql
# MAGIC USE CATALOG bfsi_lakehouse;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Gold 1: Daily Transaction Summary
# MAGIC -- Aggregated by day, category, and channel
# MAGIC 
# MAGIC CREATE OR REPLACE TABLE bfsi_lakehouse.gold.daily_transaction_summary
# MAGIC AS
# MAGIC SELECT
# MAGIC     transaction_day,
# MAGIC     category,
# MAGIC     channel,
# MAGIC     transaction_type,
# MAGIC     COUNT(*)                          AS transaction_count,
# MAGIC     ROUND(SUM(amount), 2)             AS total_amount,
# MAGIC     ROUND(AVG(amount), 2)             AS avg_amount,
# MAGIC     ROUND(MIN(amount), 2)             AS min_amount,
# MAGIC     ROUND(MAX(amount), 2)             AS max_amount,
# MAGIC     SUM(CASE WHEN is_high_value THEN 1 ELSE 0 END) AS high_value_count
# MAGIC FROM bfsi_lakehouse.silver.transactions
# MAGIC GROUP BY transaction_day, category, channel, transaction_type;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Gold 2: Account Spending Profile
# MAGIC -- Per-account aggregates for customer analytics
# MAGIC 
# MAGIC CREATE OR REPLACE TABLE bfsi_lakehouse.gold.account_spending_profile
# MAGIC AS
# MAGIC SELECT
# MAGIC     account_id,
# MAGIC     COUNT(*)                          AS total_transactions,
# MAGIC     ROUND(SUM(amount), 2)             AS total_spent,
# MAGIC     ROUND(AVG(amount), 2)             AS avg_transaction,
# MAGIC     COUNT(DISTINCT category)          AS category_diversity,
# MAGIC     COUNT(DISTINCT channel)           AS channel_diversity,
# MAGIC     ROUND(SUM(CASE WHEN transaction_type = 'DEBIT' THEN amount ELSE 0 END), 2)  AS total_debits,
# MAGIC     ROUND(SUM(CASE WHEN transaction_type = 'CREDIT' THEN amount ELSE 0 END), 2) AS total_credits,
# MAGIC     MIN(transaction_date)             AS first_transaction,
# MAGIC     MAX(transaction_date)             AS last_transaction,
# MAGIC     -- Spending pattern
# MAGIC     ROUND(
# MAGIC         SUM(CASE WHEN transaction_hour BETWEEN 6 AND 12 THEN amount ELSE 0 END) /
# MAGIC         NULLIF(SUM(amount), 0) * 100, 2
# MAGIC     ) AS morning_spend_pct,
# MAGIC     ROUND(
# MAGIC         SUM(CASE WHEN transaction_hour BETWEEN 12 AND 18 THEN amount ELSE 0 END) /
# MAGIC         NULLIF(SUM(amount), 0) * 100, 2
# MAGIC     ) AS afternoon_spend_pct,
# MAGIC     ROUND(
# MAGIC         SUM(CASE WHEN transaction_hour BETWEEN 18 AND 24 THEN amount ELSE 0 END) /
# MAGIC         NULLIF(SUM(amount), 0) * 100, 2
# MAGIC     ) AS evening_spend_pct
# MAGIC FROM bfsi_lakehouse.silver.transactions
# MAGIC GROUP BY account_id;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Gold 3: Channel Performance Analytics
# MAGIC 
# MAGIC CREATE OR REPLACE TABLE bfsi_lakehouse.gold.channel_analytics
# MAGIC AS
# MAGIC SELECT
# MAGIC     channel,
# MAGIC     transaction_day,
# MAGIC     COUNT(*)                          AS transaction_count,
# MAGIC     ROUND(SUM(amount), 2)             AS total_volume,
# MAGIC     ROUND(AVG(amount), 2)             AS avg_transaction_size,
# MAGIC     COUNT(DISTINCT account_id)        AS unique_accounts,
# MAGIC     -- Channel share
# MAGIC     ROUND(
# MAGIC         COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY transaction_day), 2
# MAGIC     ) AS daily_share_pct
# MAGIC FROM bfsi_lakehouse.silver.transactions
# MAGIC GROUP BY channel, transaction_day;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Verify Gold layer
# MAGIC SELECT 'daily_transaction_summary' AS gold_table, COUNT(*) AS rows FROM bfsi_lakehouse.gold.daily_transaction_summary
# MAGIC UNION ALL
# MAGIC SELECT 'account_spending_profile', COUNT(*) FROM bfsi_lakehouse.gold.account_spending_profile
# MAGIC UNION ALL
# MAGIC SELECT 'channel_analytics', COUNT(*) FROM bfsi_lakehouse.gold.channel_analytics;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Quick analytics: Top spending categories
# MAGIC SELECT category, 
# MAGIC        SUM(transaction_count) AS total_txns,
# MAGIC        SUM(total_amount) AS total_volume
# MAGIC FROM bfsi_lakehouse.gold.daily_transaction_summary
# MAGIC WHERE transaction_type = 'DEBIT'
# MAGIC GROUP BY category
# MAGIC ORDER BY total_volume DESC;

# COMMAND ----------

# MAGIC %sql
# MAGIC -- Quick analytics: Channel distribution
# MAGIC SELECT channel, 
# MAGIC        SUM(transaction_count) AS total_txns,
# MAGIC        SUM(total_volume) AS total_volume
# MAGIC FROM bfsi_lakehouse.gold.channel_analytics
# MAGIC GROUP BY channel
# MAGIC ORDER BY total_txns DESC;
