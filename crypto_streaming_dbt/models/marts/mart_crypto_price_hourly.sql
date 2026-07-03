with enriched as (
    select * from {{ ref('int_crypto_prices_enriched') }}
),

hourly as (
    select
        coin_id,
        timestamp_trunc(publish_time, hour) as price_hour,
        array_agg(price_usd order by publish_time asc limit 1)[offset(0)] as open_price,
        array_agg(price_usd order by publish_time desc limit 1)[offset(0)] as close_price,
        max(price_usd) as high_price,
        min(price_usd) as low_price,
        avg(volume_24h) as avg_volume_24h,
        count(*) as snapshot_count
    from enriched
    group by coin_id, price_hour
)

select * from hourly
order by coin_id, price_hour
