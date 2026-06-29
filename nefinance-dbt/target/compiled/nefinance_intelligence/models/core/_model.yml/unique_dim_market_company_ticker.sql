
    
    

select
    ticker as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.dim_market_company
where ticker is not null
group by ticker
having count(*) > 1


