select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select business_performance_month_key
from NEFINANCE_DB.DEV.mart_saas_business_performance_monthly
where business_performance_month_key is null



      
    ) dbt_internal_test