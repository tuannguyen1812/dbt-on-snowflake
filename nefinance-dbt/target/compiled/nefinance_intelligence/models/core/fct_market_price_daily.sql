

with prices as (

    select * from NEFINANCE_DB.DEV.int_market_prices_daily
    
        where price_date >= (
            select dateadd(day, -7, coalesce(max(price_date), to_date('1900-01-01')))
            from NEFINANCE_DB.DEV.fct_market_price_daily
        )
    

),

companies as (

    select company_key, ticker
    from NEFINANCE_DB.DEV.dim_market_company

)

select
    prices.market_price_day_key,
    companies.company_key,
    to_number(to_varchar(prices.price_date, 'YYYYMMDD')) as price_date_key,
    prices.ticker,
    prices.price_date,
    prices.open_price,
    prices.high_price,
    prices.low_price,
    prices.close_price,
    prices.adjusted_close_price,
    prices.volume,
    prices.previous_adjusted_close_price,
    prices.daily_return_pct,
    prices.adjusted_close_30d_avg,
    prices.volume_30d_avg,
    prices.high_price_52w,
    prices.low_price_52w,
    prices.pct_of_52w_high,
    prices.fivetran_synced_at,
    current_timestamp as transformed_at
from prices
left join companies
    on prices.ticker = companies.ticker