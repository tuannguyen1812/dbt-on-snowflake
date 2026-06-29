{{ config(
    materialized = 'incremental',
    unique_key = 'subscription_mrr_movement_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns',
    cluster_by = ['movement_date', 'account_id']
) }}

with movements as (

    select * from {{ ref('int_nefinance_subscription_mrr_movements') }}
    {% if is_incremental() %}
        where movement_date >= (
            select dateadd(month, -2, coalesce(max(movement_date), to_date('1900-01-01')))
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
    md5(
        coalesce(movements.subscription_id, 'unknown')
        || '|'
        || coalesce(to_varchar(movements.movement_date, 'YYYY-MM-DD'), 'unknown')
    ) as subscription_mrr_movement_key,
    accounts.account_key,
    subscriptions.subscription_key,
    to_number(to_varchar(movements.movement_date, 'YYYYMMDD')) as movement_date_key,
    movements.subscription_id,
    movements.account_id,
    movements.plan_tier,
    movements.billing_frequency,
    movements.movement_date,
    movements.movement_month,
    movements.end_date,
    movements.seats,
    movements.previous_account_mrr,
    movements.mrr_amount,
    movements.arr_amount,
    movements.mrr_delta,
    movements.new_mrr,
    movements.expansion_mrr,
    movements.contraction_mrr,
    movements.churn_mrr,
    movements.mrr_movement_type,
    movements.subscription_status,
    movements.auto_renew_flag,
    movements.upgrade_flag,
    movements.downgrade_flag,
    movements.churn_flag,
    movements.is_trial,
    movements.loaded_at,
    current_timestamp as transformed_at
from movements
left join accounts
    on movements.account_id = accounts.account_id
left join subscriptions
    on movements.subscription_id = subscriptions.subscription_id
