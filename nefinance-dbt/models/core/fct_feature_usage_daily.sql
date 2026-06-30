{{ config(
    materialized = 'incremental',
    unique_key = 'account_feature_usage_day_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns',
    cluster_by = ['usage_date', 'account_id']
) }}

with usage as (

    select * from {{ ref('int_nefinance_account_feature_usage_daily') }}
    {% if is_incremental() %}
        where usage_date >= (
            select dateadd(day, -3, coalesce(max(usage_date), to_date('1900-01-01')))
            from {{ this }}
        )
    {% endif %}

),

accounts as (

    select account_key, account_id
    from {{ ref('dim_account') }}

),

subscriptions as (

    select subscription_key, subscription_id
    from {{ ref('dim_subscription') }}

)

select
    usage.account_feature_usage_day_key,
    accounts.account_key,
    subscriptions.subscription_key,
    md5(usage.feature_name) as feature_key,
    {{ date_key('usage.usage_date') }} as usage_date_key,
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
