select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select subscription_id
from NEFINANCE_DB.DEV.int_nefinance_account_feature_usage_daily
where subscription_id is null



      
    ) dbt_internal_test