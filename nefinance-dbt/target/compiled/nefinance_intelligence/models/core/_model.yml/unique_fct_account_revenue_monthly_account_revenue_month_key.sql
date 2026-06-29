
    
    

select
    account_revenue_month_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.fct_account_revenue_monthly
where account_revenue_month_key is not null
group by account_revenue_month_key
having count(*) > 1


