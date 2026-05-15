# BFSI Lakehouse Pipeline

End-to-end data engineering pipeline demonstrating Databricks Lakehouse architecture with Snowflake as an external source.

## Architecture

```
Snowflake (BFSI_SOURCE)          Databricks Free Edition (AWS)
┌─────────────────────┐          ┌──────────────────────────────┐
│ CUSTOMERS           │  Lakeflow│ Bronze                       │
│ ACCOUNTS            │  Connect │   ├── transactions_batch     │
│ TRANSACTIONS        │─────────→│   │   (COPY INTO)            │
│                     │          │   └── transactions_streaming  │
│                     │          │       (Auto Loader)           │
└─────────────────────┘          │                              │
                                 │ Silver                       │
JSON files in UC Volume          │   └── transactions           │
┌─────────────────────┐          │       (MERGE INTO dedup)     │
│ transactions_       │  Auto    │                              │
│   20241206.json     │  Loader  │ Gold                         │
│ transactions_       │  + COPY  │   ├── daily_transaction_     │
│   20241207.json     │  INTO    │   │   summary                │
└─────────────────────┘──────────│   ├── account_spending_      │
                                 │   │   profile                │
                                 │   └── channel_analytics      │
                                 └──────────────────────────────┘
```

## What This Project Demonstrates

| Concept | Implementation |
|---------|---------------|
| **COPY INTO** | Batch load historical JSON from UC Volume |
| **Auto Loader** | Streaming ingestion with `cloudFiles` format |
| **Medallion Architecture** | Bronze → Silver → Gold layers |
| **Schema Enforcement** | Delta Lake schema-on-write |
| **MERGE INTO** | Insert-only merge for deduplication |
| **Generated Columns** | `transaction_day` derived from timestamp |
| **Unity Catalog** | 3-level namespace: `catalog.schema.table` |
| **Lakeflow Jobs** | DAG orchestration with task dependencies |
| **Declarative Automation Bundles** | IaC with `databricks.yml`, variables, targets |
| **CI/CD** | GitHub Actions: validate → deploy → run |
| **Lakeflow Connect** | Snowflake managed connector (if available) |

## Setup

### Prerequisites
- Databricks Free Edition account (AWS)
- Snowflake trial account (90-day)
- GitHub account
- Databricks CLI v0.218.0+

### Step 1: Snowflake Setup
Run `snowflake_setup.sql` in your Snowflake worksheet to create the BFSI database with sample data (20 customers, 25 accounts, 50 transactions).

### Step 2: Databricks Setup
1. Log into your Databricks Free Edition workspace
2. Configure Lakeflow Connect for Snowflake (Catalog → Create Connection)
3. Upload JSON files from `data/` to a UC Volume

### Step 3: Configure CI/CD
1. Generate a Databricks Personal Access Token (Settings → Developer → Access Tokens)
2. Add GitHub Secrets:
   - `DATABRICKS_HOST`: Your workspace URL (e.g., `https://xxx.cloud.databricks.com`)
   - `DATABRICKS_TOKEN`: Your personal access token
3. Update `databricks.yml` with your workspace URL and email

### Step 4: Deploy
```bash
# Install Databricks CLI
curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh

# Authenticate
databricks configure

# Validate
databricks bundle validate -t dev

# Deploy
databricks bundle deploy -t dev

# Run
databricks bundle run -t dev bfsi_etl_pipeline
```

## Project Structure

```
bfsi-lakehouse-pipeline/
├── databricks.yml              # Bundle config (targets, variables, job DAG)
├── snowflake_setup.sql         # Snowflake source data setup
├── src/
│   ├── 01_copy_into_batch_load.py      # COPY INTO demo
│   ├── 02_autoloader_streaming.py      # Auto Loader demo
│   ├── 03_silver_transform.py          # Silver: MERGE, cleanse, enrich
│   └── 04_gold_aggregates.py           # Gold: aggregates for BI
├── data/
│   ├── transactions_20241206.json      # Sample batch 1
│   └── transactions_20241207.json      # Sample batch 2
├── .github/workflows/
│   └── deploy.yml                      # GitHub Actions CI/CD
├── .gitignore
└── README.md
```

## Pipeline DAG

```
batch_load_copy_into
        │
        ▼
autoloader_streaming
        │
        ▼
  silver_transform
        │
        ▼
  gold_aggregates
```

## Tech Stack

- **Source:** Snowflake (trial), JSON files
- **Platform:** Databricks Free Edition (AWS, serverless compute)
- **Storage:** Delta Lake on Unity Catalog
- **Orchestration:** Lakeflow Jobs
- **CI/CD:** GitHub Actions + Declarative Automation Bundles
- **Languages:** Python (PySpark), SQL

## Author

