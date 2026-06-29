
    
    

select
    account_feature_usage_day_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.int_nefinance_account_feature_usage_daily
where account_feature_usage_day_key is not null
group by account_feature_usage_day_key
having count(*) > 1


