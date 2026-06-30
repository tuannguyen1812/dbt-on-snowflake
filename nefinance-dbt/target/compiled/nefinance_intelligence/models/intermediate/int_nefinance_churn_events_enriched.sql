

with churn_events as (

    select * from NEFINANCE_DB.PROD.stg_nefinance_churn_events

),

accounts as (

    select * from NEFINANCE_DB.PROD.int_nefinance_accounts

),

enriched as (

    select
        churn_events.churn_event_id,
        churn_events.account_id,
        accounts.account_name,
        accounts.country,
        accounts.industry,
        accounts.plan_tier,
        cast(churn_events.churn_date as date) as churn_date,
        date_trunc('month', cast(churn_events.churn_date as date)) as churn_month,
        lower(trim(churn_events.reason_code)) as reason_code,
        case
            when lower(churn_events.reason_code) in ('price', 'budget', 'too_expensive') then 'commercial'
            when lower(churn_events.reason_code) in ('missing_feature', 'product_gap', 'usability') then 'product'
            when lower(churn_events.reason_code) in ('support', 'poor_support', 'implementation') then 'service'
            when lower(churn_events.reason_code) in ('no_need', 'low_usage') then 'adoption'
            else 'other'
        end as reason_category,
        coalesce(churn_events.preceding_upgrade_flag, false) as preceding_upgrade_flag,
        coalesce(churn_events.preceding_downgrade_flag, false) as preceding_downgrade_flag,
        coalesce(churn_events.is_reactivation, false) as is_reactivation,
        churn_events.feedback_text,
        coalesce(churn_events.refund_amount_usd, 0) as refund_amount_usd,
        churn_events.record_id,
        churn_events.loaded_at
    from churn_events
    left join accounts
        on churn_events.account_id = accounts.account_id

)

select * from enriched