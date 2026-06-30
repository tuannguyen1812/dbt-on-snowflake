

with news as (

    select * from NEFINANCE_DB.PROD.int_market_news_daily
    

)

select
    market_news_day_key,
    md5(coalesce(source, 'unknown') || '|' || coalesce(news_topic, 'unknown')) as market_news_topic_key,
    to_number(to_varchar(published_date, 'YYYYMMDD')) as published_date_key,
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