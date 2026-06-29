{{ config(materialized = 'table') }}

with all_prices as (

    select * from {{ ref('fct_market_price_daily') }}

),

latest_prices as (

    select *
    from all_prices
    qualify row_number() over (
        partition by ticker
        order by price_date desc
    ) = 1

),

previous_prices as (

    select
        all_prices.ticker,
        all_prices.adjusted_close_price as adjusted_close_price_30d_ago
    from all_prices
    inner join latest_prices
        on all_prices.ticker = latest_prices.ticker
        and all_prices.price_date <= dateadd(day, -30, latest_prices.price_date)
    qualify row_number() over (
        partition by all_prices.ticker
        order by all_prices.price_date desc
    ) = 1

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

latest_market_news as (

    select
        published_date,
        sum(article_count) as market_article_count,
        avg(sentiment_score) as market_sentiment_score
    from {{ ref('fct_financial_news_daily') }}
    group by 1
    qualify row_number() over (
        order by published_date desc
    ) = 1

)

select
    latest_prices.company_key,
    latest_prices.ticker,
    companies.cik,
    latest_prices.price_date as latest_price_date,
    latest_prices.close_price,
    latest_prices.adjusted_close_price,
    latest_prices.daily_return_pct,
    case
        when previous_prices.adjusted_close_price_30d_ago is null
            or previous_prices.adjusted_close_price_30d_ago = 0 then null
        else (
            latest_prices.adjusted_close_price
            - previous_prices.adjusted_close_price_30d_ago
        ) / previous_prices.adjusted_close_price_30d_ago
    end as return_30d_pct,
    latest_prices.adjusted_close_30d_avg,
    latest_prices.volume,
    latest_prices.volume_30d_avg,
    latest_prices.high_price_52w,
    latest_prices.low_price_52w,
    latest_prices.pct_of_52w_high,
    latest_financials.fiscal_year as latest_fiscal_year,
    latest_financials.current_ratio,
    latest_financials.liability_to_asset_ratio,
    latest_financials.return_on_assets,
    latest_financials.return_on_equity,
    latest_financials.earnings_per_share_basic,
    latest_market_news.market_article_count,
    latest_market_news.market_sentiment_score,
   case
    when daily_return_pct <= -0.03
        or return_30d_pct <= -0.08
        or (
            pct_of_52w_high <= 0.75
            and coalesce(market_sentiment_score, 0) <= 0
        ) then 'risk_watch'

    when daily_return_pct >= 0.03
        or return_30d_pct >= 0.08
        or (
            pct_of_52w_high >= 0.95
            and coalesce(market_sentiment_score, 0) >= 0
        ) then 'momentum_watch'

    when pct_of_52w_high >= 0.95 then 'near_high'

    else 'normal'
end as watch_status,
    current_timestamp as transformed_at
from latest_prices
left join previous_prices
    on latest_prices.ticker = previous_prices.ticker
left join companies
    on latest_prices.company_key = companies.company_key
left join latest_financials
    on latest_prices.company_key = latest_financials.company_key
left join latest_market_news
    on 1 = 1
