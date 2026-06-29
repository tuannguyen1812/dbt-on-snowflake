select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    account_feature_usage_day_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.fct_feature_usage_daily
where account_feature_usage_day_key is not null
group by account_feature_usage_day_key
having count(*) > 1



      
    ) dbt_internal_test