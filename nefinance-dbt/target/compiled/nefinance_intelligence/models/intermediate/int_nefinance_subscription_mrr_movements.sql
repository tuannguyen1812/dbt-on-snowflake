

with subscriptions as (

    select * from NEFINANCE_DB.PROD.int_nefinance_subscriptions

),

with_previous as (

    select
        subscriptions.*,
        lag(mrr_amount) over (
            partition by account_id
            order by start_date, subscription_id
        ) as previous_account_mrr
    from subscriptions

),

classified as (

    select
        subscription_id,
        account_id,
        plan_tier,
        billing_frequency,
        start_date as movement_date,
        start_month as movement_month,
        end_date,
        seats,
        mrr_amount,
        arr_amount,
        coalesce(previous_account_mrr, 0) as previous_account_mrr,
        mrr_amount - coalesce(previous_account_mrr, 0) as mrr_delta,
        case
            when churn_flag then 'churn'
            when is_trial then 'trial'
            when previous_account_mrr is null then 'new'
            when upgrade_flag or mrr_amount > previous_account_mrr then 'expansion'
            when downgrade_flag or mrr_amount < previous_account_mrr then 'contraction'
            else 'renewal'
        end as mrr_movement_type,
        case
            when previous_account_mrr is null and not is_trial then mrr_amount
            else 0
        end as new_mrr,
        case
            when not churn_flag and mrr_amount > coalesce(previous_account_mrr, 0)
                then mrr_amount - coalesce(previous_account_mrr, 0)
            else 0
        end as expansion_mrr,
        case
            when not churn_flag and previous_account_mrr is not null and mrr_amount < previous_account_mrr
                then previous_account_mrr - mrr_amount
            else 0
        end as contraction_mrr,
        case
            when churn_flag then greatest(coalesce(previous_account_mrr, mrr_amount), mrr_amount)
            else 0
        end as churn_mrr,
        subscription_status,
        auto_renew_flag,
        upgrade_flag,
        downgrade_flag,
        churn_flag,
        is_trial,
        loaded_at
    from with_previous

)

select * from classified