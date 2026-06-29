{{ config(materialized = 'view') }}

with subscriptions as (

    select * from {{ ref('stg_nefinance_subscriptions') }}

),

cleaned as (

    select
        subscription_id,
        account_id,
        lower(trim(plan_tier)) as plan_tier,
        lower(trim(billing_frequency)) as billing_frequency,
        cast(start_date as date) as start_date,
        cast(end_date as date) as end_date,
        coalesce(seats, 0) as seats,
        coalesce(mrr_amount, 0) as mrr_amount,
        coalesce(arr_amount, 0) as arr_amount,
        coalesce(auto_renew_flag, false) as auto_renew_flag,
        coalesce(upgrade_flag, false) as upgrade_flag,
        coalesce(downgrade_flag, false) as downgrade_flag,
        coalesce(churn_flag, false) as churn_flag,
        coalesce(is_trial, false) as is_trial,
        record_id,
        loaded_at
    from subscriptions

),

enriched as (

    select
        subscription_id,
        account_id,
        plan_tier,
        billing_frequency,
        start_date,
        end_date,
        date_trunc('month', start_date) as start_month,
        date_trunc('month', end_date) as end_month,
        seats,
        mrr_amount,
        arr_amount,
        case
            when seats = 0 then 0
            else mrr_amount / seats
        end as mrr_per_seat,
        auto_renew_flag,
        upgrade_flag,
        downgrade_flag,
        churn_flag,
        is_trial,
        case
            when churn_flag then 'churned'
            when is_trial then 'trial'
            when end_date is not null and end_date < current_date then 'ended'
            when start_date > current_date then 'scheduled'
            else 'active'
        end as subscription_status,
        datediff(day, start_date, coalesce(end_date, current_date)) as subscription_term_days,
        record_id,
        loaded_at
    from cleaned

)

select * from enriched
