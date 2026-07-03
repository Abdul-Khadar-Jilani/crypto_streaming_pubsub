with source as (
    select * from {{ source('streaming_raw', 'crypto_prices') }}
),

deduped as (
    select
        message_id,
        coin_id,
        currency,
        price_usd,
        market_cap,
        volume_24h,
        fetched_at,
        publish_time,
        row_number() over (
            partition by message_id
            order by publish_time desc
        ) as rn
    from source
    where price_usd is not null
)

select
    message_id,
    coin_id,
    currency,
    price_usd,
    market_cap,
    volume_24h,
    fetched_at,
    publish_time
from deduped
where rn = 1
