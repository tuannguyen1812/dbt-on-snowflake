
    
    

select
    company_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.dim_market_company
where company_key is not null
group by company_key
having count(*) > 1


