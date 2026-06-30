

with news as (

    select * from NEFINANCE_DB.PROD.fct_financial_news_daily
    

)

select
    market_news_day_key,
    published_date_key,
    source,
    published_date,
    news_topic,
    article_count,
    positive_article_count,
    neutral_article_count,
    negative_article_count,
    sentiment_score,
    dominant_sentiment,
    case
        when sentiment_score >= 0.25 then 'positive_market_tone'
        when sentiment_score <= -0.25 then 'negative_market_tone'
        else 'neutral_market_tone'
    end as market_tone_signal,
    headline_rollup,
    latest_sentiment_classified_at,
    latest_loaded_at,
    current_timestamp as transformed_at
from news