with staged as (
    select * from {{ ref('stg_crypto_prices') }}
),

with_lag as (
    select
        *,
        lag(price_usd) over (
            partition by coin_id order by publish_time
        ) as prev_price_usd,
        lag(publish_time) over (
            partition by coin_id order by publish_time
        ) as prev_publish_time
    from staged
)

select
    *,
    round(safe_divide(price_usd - prev_price_usd, prev_price_usd) * 100, 4) as pct_change_since_last,
    timestamp_diff(publish_time, prev_publish_time, second) as seconds_since_last_snapshot
from with_lag
