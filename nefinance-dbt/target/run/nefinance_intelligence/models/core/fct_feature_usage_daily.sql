
  
    

        create or replace transient table NEFINANCE_DB.PROD.fct_feature_usage_daily
         as
        (select * from (
              

with usage as (

    select * from NEFINANCE_DB.PROD.int_nefinance_account_feature_usage_daily
    

),

accounts as (

    select account_key, account_id
    from NEFINANCE_DB.PROD.dim_account

),

subscriptions as (

    select subscription_key, subscription_id
    from NEFINANCE_DB.PROD.dim_subscription

)

select
    usage.account_feature_usage_day_key,
    accounts.account_key,
    subscriptions.subscription_key,
    md5(usage.feature_name) as feature_key,
    to_number(to_varchar(usage.usage_date, 'YYYYMMDD')) as usage_date_key,
    usage.account_id,
    usage.subscription_id,
    usage.feature_name,
    usage.usage_date,
    usage.usage_count,
    usage.usage_duration_secs,
    usage.error_count,
    usage.usage_event_count,
    usage.has_beta_feature_usage,
    usage.error_rate,
    usage.latest_loaded_at,
    current_timestamp as transformed_at
from usage
left join accounts
    on usage.account_id = accounts.account_id
left join subscriptions
    on usage.subscription_id = subscriptions.subscription_id
              ) order by (usage_date, account_id)
        );
      alter  table NEFINANCE_DB.PROD.fct_feature_usage_daily cluster by (usage_date, account_id);
  