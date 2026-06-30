
    
    

select
    business_performance_month_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.mart_saas_business_performance_monthly
where business_performance_month_key is not null
group by business_performance_month_key
having count(*) > 1


