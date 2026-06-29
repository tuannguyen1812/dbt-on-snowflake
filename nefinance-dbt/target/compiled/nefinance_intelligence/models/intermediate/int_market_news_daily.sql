

with all_news as (

    select * from NEFINANCE_DB.DEV.int_market_news_sentiment

),

impacted_groups as (

    select
        source,
        published_date,
        news_topic
    from all_news
    
        where sentiment_classified_at >= (
            select coalesce(
                max(latest_sentiment_classified_at),
                to_timestamp_tz('1900-01-01 00:00:00 +00:00')
            )
            from NEFINANCE_DB.DEV.int_market_news_daily
        )
    
    group by 1, 2, 3

),

news as (

    select all_news.*
    from all_news
    inner join impacted_groups
        on all_news.source = impacted_groups.source
        and all_news.published_date = impacted_groups.published_date
        and all_news.news_topic = impacted_groups.news_topic

),

daily as (

    select
        source,
        published_date,
        news_topic,
        count(*) as article_count,
        count_if(sentiment = 'Positive') as positive_article_count,
        count_if(sentiment = 'Neutral') as neutral_article_count,
        count_if(sentiment = 'Negative') as negative_article_count,
        avg(case
            when sentiment = 'Positive' then 1
            when sentiment = 'Negative' then -1
            else 0
        end) as sentiment_score,
        case
            when count_if(sentiment = 'Positive') >= greatest(
                count_if(sentiment = 'Neutral'),
                count_if(sentiment = 'Negative')
            ) then 'Positive'
            when count_if(sentiment = 'Negative') >= greatest(
                count_if(sentiment = 'Positive'),
                count_if(sentiment = 'Neutral')
            ) then 'Negative'
            else 'Neutral'
        end as dominant_sentiment,
        listagg(headline, ' | ') within group (order by headline) as headline_rollup,
        max(sentiment_classified_at) as latest_sentiment_classified_at,
        max(loaded_at) as latest_loaded_at
    from news
    group by 1, 2, 3

)

select
    concat(source, '|', to_varchar(published_date, 'YYYY-MM-DD'), '|', news_topic) as market_news_day_key,
    *
from daily