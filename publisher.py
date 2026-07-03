# publisher.py
import json
import time
from datetime import datetime, timezone
from google.cloud import pubsub_v1
from google.oauth2 import service_account
import requests

PROJECT_ID = "gen-lang-client-0461437803"
TOPIC_ID = "crypto-prices"
SERVICE_ACCOUNT_FILE = "config/gcp-key.json"
credentials = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE)
publisher = pubsub_v1.PublisherClient(credentials=credentials)
topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)

COINS = ["bitcoin", "ethereum", "solana"]

def fetch_prices():
    url = "https://api.coingecko.com/api/v3/simple/price"
    params = {
        "ids": ",".join(COINS),
        "vs_currencies": "usd",
        "include_market_cap": "true",
        "include_24hr_vol": "true"
    }
    return requests.get(url, params=params).json()

def publish(data: dict):
    message = json.dumps(data).encode("utf-8")
    future = publisher.publish(topic_path, message)
    try:
        future.result()
        return True
    except Exception as e:
        print(f"Error publishing: {e}")
        return False

while True:
    prices = fetch_prices()
    for coin, metrics in prices.items():
        record = {
            "coin_id": coin,
            "currency": "usd",
            "price_usd": metrics["usd"],
            "market_cap": metrics["usd_market_cap"],
            "volume_24h": metrics["usd_24h_vol"],
            "fetched_at": datetime.now(timezone.utc).isoformat()
        }
        success=publish(record)
        print(f"Published: {record}") if success else print(f"Failed to publish: {record}")
    time.sleep(30)