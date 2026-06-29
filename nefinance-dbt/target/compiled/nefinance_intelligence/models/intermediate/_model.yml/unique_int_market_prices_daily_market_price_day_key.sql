
    
    

select
    market_price_day_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.int_market_prices_daily
where market_price_day_key is not null
group by market_price_day_key
having count(*) > 1


