

with prices as (

    select * from NEFINANCE_DB.DEV.stg_sp500_prices
    
        where price_date >= (
            select dateadd(day, -370, coalesce(max(price_date), to_date('1900-01-01')))
            from NEFINANCE_DB.DEV.int_market_prices_daily
        )
    

),

windowed as (

    select
        ticker,
        price_date,
        open_price,
        high_price,
        low_price,
        close_price,
        adjusted_close_price,
        volume,
        lag(adjusted_close_price) over (
            partition by ticker
            order by price_date
        ) as previous_adjusted_close_price,
        avg(adjusted_close_price) over (
            partition by ticker
            order by price_date
            rows between 29 preceding and current row
        ) as adjusted_close_30d_avg,
        avg(volume) over (
            partition by ticker
            order by price_date
            rows between 29 preceding and current row
        ) as volume_30d_avg,
        max(high_price) over (
            partition by ticker
            order by price_date
            rows between 251 preceding and current row
        ) as high_price_52w,
        min(low_price) over (
            partition by ticker
            order by price_date
            rows between 251 preceding and current row
        ) as low_price_52w,
        fivetran_synced_at
    from prices

)

select
    concat(ticker, '|', to_varchar(price_date, 'YYYY-MM-DD')) as market_price_day_key,
    ticker,
    price_date,
    open_price,
    high_price,
    low_price,
    close_price,
    adjusted_close_price,
    volume,
    previous_adjusted_close_price,
    case
        when previous_adjusted_close_price is null or previous_adjusted_close_price = 0 then null
        else (adjusted_close_price - previous_adjusted_close_price) / previous_adjusted_close_price
    end as daily_return_pct,
    adjusted_close_30d_avg,
    volume_30d_avg,
    high_price_52w,
    low_price_52w,
    case
        when high_price_52w is null or high_price_52w = 0 then null
        else adjusted_close_price / high_price_52w
    end as pct_of_52w_high,
    fivetran_synced_at
from windowed

    where price_date >= (
        select dateadd(day, -7, coalesce(max(price_date), to_date('1900-01-01')))
        from NEFINANCE_DB.DEV.int_market_prices_daily
    )
