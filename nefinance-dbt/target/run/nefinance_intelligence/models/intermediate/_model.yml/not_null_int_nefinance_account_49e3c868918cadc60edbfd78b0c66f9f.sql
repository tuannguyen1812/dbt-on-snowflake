select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select account_feature_usage_day_key
from NEFINANCE_DB.DEV.int_nefinance_account_feature_usage_daily
where account_feature_usage_day_key is null



      
    ) dbt_internal_test