{{ config(materialized = 'view') }}

with usage as (

    select * from {{ ref('int_nefinance_account_feature_usage_daily') }}

),

features as (

    select
        feature_name,
        boolor_agg(has_beta_feature_usage) as has_beta_feature_usage,
        min(usage_date) as first_usage_date,
        max(usage_date) as latest_usage_date,
        max(latest_loaded_at) as latest_loaded_at
    from usage
    where feature_name is not null
    group by 1

)

select
    md5(feature_name) as feature_key,
    feature_name,
    has_beta_feature_usage,
    first_usage_date,
    latest_usage_date,
    latest_loaded_at,
    current_timestamp as transformed_at
from features
