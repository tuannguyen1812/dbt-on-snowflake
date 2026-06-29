{{ config(
    materialized = 'incremental',
    unique_key = 'market_price_day_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns',
    cluster_by = ['price_date', 'ticker']
) }}

with prices as (

    select * from {{ ref('fct_market_price_daily') }}
    {% if is_incremental() %}
        where price_date >= (
            select dateadd(day, -7, coalesce(max(price_date), to_date('1900-01-01')))
            from {{ this }}
        )
    {% endif %}

),

companies as (

    select * from {{ ref('dim_market_company') }}

),

latest_financials as (

    select *
    from {{ ref('fct_company_financials_yearly') }}
    qualify row_number() over (
        partition by ticker
        order by fiscal_year desc, report_date desc
    ) = 1

),

news_by_date as (

    select
        published_date,
        sum(article_count) as market_article_count,
        sum(positive_article_count) as market_positive_article_count,
        sum(neutral_article_count) as market_neutral_article_count,
        sum(negative_article_count) as market_negative_article_count,
        avg(sentiment_score) as market_sentiment_score,
        case
            when sum(positive_article_count) >= greatest(
                sum(neutral_article_count),
                sum(negative_article_count)
            ) then 'Positive'
            when sum(negative_article_count) >= greatest(
                sum(positive_article_count),
                sum(neutral_article_count)
            ) then 'Negative'
            else 'Neutral'
        end as market_dominant_sentiment
    from {{ ref('fct_financial_news_daily') }}
    {% if is_incremental() %}
        where published_date >= (
            select dateadd(day, -7, coalesce(max(price_date), to_date('1900-01-01')))
            from {{ this }}
        )
    {% endif %}
    group by 1

)

select
    prices.market_price_day_key,
    prices.company_key,
    prices.price_date_key,
    prices.ticker,
    companies.cik,
    prices.price_date,
    prices.open_price,
    prices.high_price,
    prices.low_price,
    prices.close_price,
    prices.adjusted_close_price,
    prices.volume,
    prices.daily_return_pct,
    prices.adjusted_close_30d_avg,
    prices.volume_30d_avg,
    case
        when prices.volume_30d_avg is null or prices.volume_30d_avg = 0 then null
        else prices.volume / prices.volume_30d_avg
    end as volume_vs_30d_avg_ratio,
    prices.high_price_52w,
    prices.low_price_52w,
    prices.pct_of_52w_high,
    latest_financials.current_ratio,
    latest_financials.liability_to_asset_ratio,
    latest_financials.return_on_assets,
    latest_financials.return_on_equity,
    latest_financials.earnings_per_share_basic,
    coalesce(news_by_date.market_article_count, 0) as market_article_count,
    coalesce(news_by_date.market_positive_article_count, 0) as market_positive_article_count,
    coalesce(news_by_date.market_neutral_article_count, 0) as market_neutral_article_count,
    coalesce(news_by_date.market_negative_article_count, 0) as market_negative_article_count,
    news_by_date.market_sentiment_score,
    coalesce(news_by_date.market_dominant_sentiment, 'Neutral') as market_dominant_sentiment,
    case
        when prices.daily_return_pct >= 0.03
            and coalesce(news_by_date.market_sentiment_score, 0) >= 0 then 'bullish_watch'
        when prices.daily_return_pct <= -0.03
            or coalesce(news_by_date.market_sentiment_score, 0) < -0.25 then 'risk_watch'
        when prices.pct_of_52w_high >= 0.95 then 'near_52w_high'
        when prices.pct_of_52w_high <= 0.75 then 'below_52w_high'
        else 'normal'
    end as market_watch_signal,
    current_timestamp as transformed_at
from prices
left join companies
    on prices.company_key = companies.company_key
left join latest_financials
    on prices.company_key = latest_financials.company_key
left join news_by_date
    on prices.price_date = news_by_date.published_date
