{{ config(
    materialized = 'incremental',
    unique_key = 'churn_event_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns',
    cluster_by = ['churn_date', 'account_id']
) }}

with churn_events as (

    select * from {{ ref('int_nefinance_churn_events_enriched') }}
    {% if is_incremental() %}
        where loaded_at >= (
            select coalesce(
                max(latest_loaded_at),
                to_timestamp_tz('1900-01-01 00:00:00 +00:00')
            )
            from {{ this }}
        )
    {% endif %}

),

accounts as (

    select account_key, account_id
    from {{ ref('dim_account') }}

)

select
    md5(churn_events.churn_event_id) as churn_event_key,
    accounts.account_key,
   {{ date_key('churn_events.churn_date') }} as churn_date_key,
    churn_events.churn_event_id,
    churn_events.account_id,
    churn_events.churn_date,
    churn_events.churn_month,
    churn_events.reason_code,
    churn_events.reason_category,
    churn_events.preceding_upgrade_flag,
    churn_events.preceding_downgrade_flag,
    churn_events.is_reactivation,
    churn_events.feedback_text,
    churn_events.refund_amount_usd,
    churn_events.record_id,
    churn_events.loaded_at as latest_loaded_at,
    current_timestamp as transformed_at
from churn_events
left join accounts
    on churn_events.account_id = accounts.account_id
