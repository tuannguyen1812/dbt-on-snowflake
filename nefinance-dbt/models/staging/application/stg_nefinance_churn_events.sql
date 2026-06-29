{{ config(materialized='view') }}

select

    churn_event_id,
    account_id,

    churn_date,

    reason_code,

    preceding_upgrade_flag,
    preceding_downgrade_flag,

    is_reactivation,

    feedback_text,

    try_to_number(refund_amount_usd::varchar) as refund_amount_usd,

    ctid_fivetran_id as record_id,

    _fivetran_synced as loaded_at

from {{ source('nefinance','NEFINANCE_CHURN_EVENTS') }}

where not coalesce(_fivetran_deleted,false)