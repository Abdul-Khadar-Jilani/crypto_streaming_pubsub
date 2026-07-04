# Crypto Streaming Data Pipeline (dbt)

This repository contains a dbt (data build tool) project that processes cryptocurrency streaming data stored in BigQuery. The project applies data quality checks, deduplication, and various aggregations to produce analytics-ready datasets.

## How it Works

The pipeline follows a standard dbt architecture containing three core stages: **Staging**, **Intermediate**, and **Marts**. The raw data is continuously streamed into a BigQuery dataset (`streaming_raw`).

### 1. Staging (`models/staging`)
The staging layer acts as the entry point for raw data into the dbt project. It performs basic cleaning and standardizations.

* **`stg_crypto_prices.sql`**: Reads from the raw BigQuery source table. It ensures that the data is clean by filtering out rows with null `price_usd` and deduplicates records (based on `message_id`) by taking the most recent `publish_time`.

### 2. Intermediate (`models/intermediate`)
The intermediate layer builds upon the staging layer by adding complex calculations and preparing the data for final business models.

* **`int_crypto_prices_enriched.sql`**: Takes the cleaned staging data and enriches it. It uses window functions (`lag`) to look up the previous price for each `coin_id` (ordered by `publish_time`) and calculates the percentage change in price since the last data point (`pct_change_since_last`).

### 3. Marts (`models/marts`)
The marts layer contains the final, business-ready models designed for dashboards, reporting, and analytics.

* **`mart_latest_prices.sql`**: Extracts the absolute latest price snapshot for each cryptocurrency. It uses a ranking function to retrieve only the most recent row per `coin_id`, providing a real-time view of current market prices, volume, and recent price changes.
* **`mart_crypto_price_hourly.sql`**: Aggregates the enriched data into hourly intervals. For each hour and coin, it calculates the Open, High, Low, and Close (OHLC) prices, as well as the average 24-hour volume and the number of snapshots received during that hour.
* **`mart_crypto_volatility_daily.sql`**: Aggregates the data to a daily grain to measure volatility. It calculates the daily high and low prices, the standard deviation of the price, and the daily price range as a percentage.

## Running the Project

To execute the models in this project, ensure you are in the `crypto_streaming_dbt` directory and run:

```bash
dbt run
```

To run data quality tests:

```bash
dbt test
```