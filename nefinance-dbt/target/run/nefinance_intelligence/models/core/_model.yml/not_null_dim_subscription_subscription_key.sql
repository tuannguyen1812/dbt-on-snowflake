select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select subscription_key
from NEFINANCE_DB.DEV.dim_subscription
where subscription_key is null



      
    ) dbt_internal_test