

with usage as (

    select * from NEFINANCE_DB.DEV.stg_nefinance_feature_usage
    
        where cast(usage_date as date) >= (
            select dateadd(day, -3, coalesce(max(usage_date), to_date('1900-01-01')))
            from NEFINANCE_DB.DEV.int_nefinance_account_feature_usage_daily
        )
    

),

subscriptions as (

    select * from NEFINANCE_DB.DEV.int_nefinance_subscriptions

),

usage_enriched as (

    select
        usage.usage_id,
        subscriptions.account_id,
        usage.subscription_id,
        lower(trim(usage.feature_name)) as feature_name,
        cast(usage.usage_date as date) as usage_date,
        coalesce(usage.usage_count, 0) as usage_count,
        coalesce(usage.usage_duration_secs, 0) as usage_duration_secs,
        coalesce(usage.error_count, 0) as error_count,
        coalesce(usage.is_beta_feature, false) as is_beta_feature,
        usage.loaded_at
    from usage
    left join subscriptions
        on usage.subscription_id = subscriptions.subscription_id

),

daily as (

    select
        account_id,
        subscription_id,
        feature_name,
        usage_date,
        sum(usage_count) as usage_count,
        sum(usage_duration_secs) as usage_duration_secs,
        sum(error_count) as error_count,
        count(distinct usage_id) as usage_event_count,
        boolor_agg(is_beta_feature) as has_beta_feature_usage,
        case
            when sum(usage_count) = 0 then 0
            else sum(error_count) / nullif(sum(usage_count), 0)
        end as error_rate,
        max(loaded_at) as latest_loaded_at
    from usage_enriched
    group by 1, 2, 3, 4

)

select
    concat(
        coalesce(account_id, 'unknown'),
        '|',
        subscription_id,
        '|',
        feature_name,
        '|',
        to_varchar(usage_date, 'YYYY-MM-DD')
    ) as account_feature_usage_day_key,
    *
from daily