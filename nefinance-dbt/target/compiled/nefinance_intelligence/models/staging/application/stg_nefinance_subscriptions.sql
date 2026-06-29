

select

    subscription_id,

    account_id,

    plan_tier,

    billing_frequency,

    start_date,

    try_to_timestamp(end_date) as end_date,

    seats,

    mrr_amount,

    arr_amount,

    auto_renew_flag,

    upgrade_flag,

    downgrade_flag,

    churn_flag,

    is_trial,

    ctid_fivetran_id as record_id,

    _fivetran_synced as loaded_at

from PC_FIVETRAN_DB.NEFINANCE_POSTGRES_PUBLIC.NEFINANCE_SUBSCRIPTIONS

where not coalesce(_fivetran_deleted,false)