with enriched as (
    select * from {{ ref('int_crypto_prices_enriched') }}
),

ranked as (
    select
        *,
        row_number() over (
            partition by coin_id order by publish_time desc
        ) as rn
    from enriched
)

select
    coin_id,
    currency,
    price_usd,
    market_cap,
    volume_24h,
    pct_change_since_last,
    publish_time as as_of
from ranked
where rn = 1
