

select
    account_id,
    account_name,
    country,
    industry,
    referral_source,
    plan_tier,

    seats,

    is_trial,
    churn_flag,

    signup_date,

    ctid_fivetran_id as record_id,

    _fivetran_synced as loaded_at

from PC_FIVETRAN_DB.NEFINANCE_POSTGRES_PUBLIC.NEFINANCE_ACCOUNTS

where not coalesce(_fivetran_deleted,false)