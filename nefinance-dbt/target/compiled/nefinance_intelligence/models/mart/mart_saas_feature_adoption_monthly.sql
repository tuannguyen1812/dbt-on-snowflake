

with usage as (

    select * from NEFINANCE_DB.DEV.fct_feature_usage_daily
    

),

features as (

    select * from NEFINANCE_DB.DEV.dim_feature

),

monthly as (

    select
        date_trunc('month', usage.usage_date) as usage_month,
        usage.feature_key,
        usage.feature_name,
        count(distinct usage.account_id) as active_account_count,
        count(distinct usage.subscription_id) as active_subscription_count,
        sum(usage.usage_count) as usage_count,
        sum(usage.usage_duration_secs) as usage_duration_secs,
        sum(usage.error_count) as error_count,
        sum(usage.usage_event_count) as usage_event_count,
        boolor_agg(usage.has_beta_feature_usage) as has_beta_feature_usage,
        max(usage.latest_loaded_at) as latest_loaded_at
    from usage
    group by 1, 2, 3

)

select
    md5(
        coalesce(monthly.feature_name, 'unknown')
        || '|'
        || coalesce(to_varchar(monthly.usage_month, 'YYYY-MM-DD'), 'unknown')
    ) as feature_adoption_month_key,
    monthly.feature_key,
    to_number(to_varchar(monthly.usage_month, 'YYYYMMDD')) as usage_month_date_key,
    monthly.usage_month,
    monthly.feature_name,
    features.first_usage_date,
    features.latest_usage_date,
    monthly.active_account_count,
    monthly.active_subscription_count,
    monthly.usage_count,
    monthly.usage_duration_secs,
    monthly.error_count,
    monthly.usage_event_count,
    monthly.has_beta_feature_usage,
    case
        when monthly.usage_count = 0 then null
        else monthly.error_count / nullif(monthly.usage_count, 0)
    end as feature_error_rate,
    case
        when monthly.active_account_count >= 10
            and (monthly.error_count / nullif(monthly.usage_count, 0)) <= 0.05 then 'scaled_adoption'
        when (monthly.error_count / nullif(monthly.usage_count, 0)) > 0.10 then 'quality_watch'
        when monthly.active_account_count < 3 then 'low_adoption'
        else 'steady'
    end as feature_adoption_status,
    monthly.latest_loaded_at,
    current_timestamp as transformed_at
from monthly
left join features
    on monthly.feature_key = features.feature_key