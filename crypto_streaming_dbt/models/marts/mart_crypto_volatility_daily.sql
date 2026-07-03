with enriched as (
    select * from {{ ref('int_crypto_prices_enriched') }}
),

daily as (
    select
        coin_id,
        date(publish_time) as price_date,
        max(price_usd) as day_high,
        min(price_usd) as day_low,
        stddev(price_usd) as price_stddev,
        round(safe_divide(max(price_usd) - min(price_usd), min(price_usd)) * 100, 4) as day_range_pct
    from enriched
    group by coin_id, price_date
)

select * from daily
order by coin_id, price_date
