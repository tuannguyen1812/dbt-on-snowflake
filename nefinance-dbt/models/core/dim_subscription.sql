{{ config(materialized = 'view') }}

with subscriptions as (

    select * from {{ ref('int_nefinance_subscriptions') }}

)

select
    md5(subscription_id) as subscription_key,
    md5(account_id) as account_key,
    subscription_id,
    account_id,
    plan_tier,
    billing_frequency,
    start_date,
    end_date,
    start_month,
    end_month,
    seats,
    mrr_per_seat,
    auto_renew_flag,
    upgrade_flag,
    downgrade_flag,
    churn_flag,
    is_trial,
    subscription_status,
    subscription_term_days,
    record_id,
    loaded_at,
    current_timestamp as transformed_at
from subscriptions
