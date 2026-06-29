select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select revenue_month
from NEFINANCE_DB.DEV.int_nefinance_account_revenue_monthly
where revenue_month is null



      
    ) dbt_internal_test