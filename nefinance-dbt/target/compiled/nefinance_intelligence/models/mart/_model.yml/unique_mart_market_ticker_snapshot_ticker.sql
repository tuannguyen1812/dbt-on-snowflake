
    
    

select
    ticker as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.mart_market_ticker_snapshot
where ticker is not null
group by ticker
having count(*) > 1


