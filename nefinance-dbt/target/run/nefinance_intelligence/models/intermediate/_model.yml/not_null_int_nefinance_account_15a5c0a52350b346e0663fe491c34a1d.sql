select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select account_revenue_month_key
from NEFINANCE_DB.DEV.int_nefinance_account_revenue_monthly
where account_revenue_month_key is null



      
    ) dbt_internal_test