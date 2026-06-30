select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select performance_month
from NEFINANCE_DB.DEV.mart_saas_business_performance_monthly
where performance_month is null



      
    ) dbt_internal_test