
    
    

select
    market_news_day_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.fct_financial_news_daily
where market_news_day_key is not null
group by market_news_day_key
having count(*) > 1


