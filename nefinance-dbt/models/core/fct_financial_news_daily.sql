{{ config(
    materialized = 'incremental',
    unique_key = 'market_news_day_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns',
    cluster_by = ['published_date', 'source']
) }}

with news as (

    select * from {{ ref('int_market_news_daily') }}
    {% if is_incremental() %}
        where latest_sentiment_classified_at >= (
            select coalesce(
                max(latest_sentiment_classified_at),
                to_timestamp_tz('1900-01-01 00:00:00 +00:00')
            )
            from {{ this }}
        )
    {% endif %}

)

select
    market_news_day_key,
    md5(coalesce(source, 'unknown') || '|' || coalesce(news_topic, 'unknown')) as market_news_topic_key,
    {{ date_key('published_date') }} as published_date_key,
    source,
    published_date,
    news_topic,
    article_count,
    positive_article_count,
    neutral_article_count,
    negative_article_count,
    sentiment_score,
    dominant_sentiment,
    headline_rollup,
    latest_sentiment_classified_at,
    latest_loaded_at,
    current_timestamp as transformed_at
from news
