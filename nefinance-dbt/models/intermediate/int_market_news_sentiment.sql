{{ config(
    materialized = 'incremental',
    unique_key = 'news_article_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns'
) }}

with source as (

    select * from {{ ref('stg_financial_news') }}

),

cleaned as (

    select
        md5(
            coalesce(lower(trim(source)), 'unknown')
            || '|'
            || coalesce(to_varchar(published_date, 'YYYY-MM-DD'), 'unknown')
            || '|'
            || coalesce(headline, '')
            || '|'
            || coalesce(description, '')
        ) as news_article_key,
        coalesce(lower(trim(source)), 'unknown') as source,
        published_date,
        headline,
        description,
        loaded_at,
        case
            when lower(coalesce(headline, '') || ' ' || coalesce(description, '')) like any (
                '%earnings%',
                '%revenue%',
                '%profit%',
                '%forecast%'
            ) then 'financial_performance'
            when lower(coalesce(headline, '') || ' ' || coalesce(description, '')) like any (
                '%rate%',
                '%inflation%',
                '%fed%',
                '%market%'
            ) then 'macro_market'
            when lower(coalesce(headline, '') || ' ' || coalesce(description, '')) like any (
                '%merger%',
                '%acquisition%',
                '%deal%',
                '%ipo%'
            ) then 'corporate_activity'
            else 'general'
        end as news_topic
    from source

),

deduplicated as (

    select *
    from cleaned
    qualify row_number() over (
        partition by news_article_key
        order by loaded_at desc
    ) = 1

),

new_articles as (

    select *
    from deduplicated
    {% if is_incremental() %}
        where not exists (
            select 1
            from {{ this }} as existing_articles
            where existing_articles.news_article_key = deduplicated.news_article_key
        )
    {% endif %}

),

scored_raw as (

    select
        news_article_key,
        source,
        published_date,
        headline,
        description,
        news_topic,
        loaded_at,
        SNOWFLAKE.CORTEX.COMPLETE(
            'llama3.1-70b',
            concat(
                'Classify this financial news as Positive, Neutral, or Negative. Return only one word. News: ',
                concat(coalesce(headline, ''), '. ', coalesce(description, ''))
            )
        ) as sentiment_raw,
        current_timestamp as sentiment_classified_at
    from new_articles

),

scored as (

    select
        news_article_key,
        source,
        published_date,
        headline,
        description,
        news_topic,
        case
            when lower(trim(sentiment_raw)) like 'positive%' then 'Positive'
            when lower(trim(sentiment_raw)) like 'negative%' then 'Negative'
            else 'Neutral'
        end as sentiment,
        sentiment_raw,
        sentiment_classified_at,
        loaded_at
    from scored_raw

)

select * from scored
