
    
    

select
    market_price_day_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.mart_market_watchlist_daily
where market_price_day_key is not null
group by market_price_day_key
having count(*) > 1


