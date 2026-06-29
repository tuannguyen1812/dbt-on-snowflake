{{ config(materialized = 'view') }}

with accounts as (

    select * from {{ ref('int_nefinance_accounts') }}

),

revenue_all as (

    select * from {{ ref('int_nefinance_account_revenue_monthly') }}

),

revenue_lifetime as (

    select
        account_id,
        sum(expansion_mrr) as lifetime_expansion_mrr,
        sum(contraction_mrr) as lifetime_contraction_mrr,
        sum(churn_mrr) as lifetime_churn_mrr
    from revenue_all
    group by 1

),

revenue_latest as (

    select
        account_id,
        revenue_month as latest_revenue_month,
        ending_mrr as current_mrr,
        ending_arr as current_arr
    from revenue_all
    qualify row_number() over (
        partition by account_id
        order by revenue_month desc
    ) = 1

),

revenue as (

    select
        revenue_lifetime.account_id,
        revenue_latest.latest_revenue_month,
        revenue_latest.current_mrr,
        revenue_latest.current_arr,
        revenue_lifetime.lifetime_expansion_mrr,
        revenue_lifetime.lifetime_contraction_mrr,
        revenue_lifetime.lifetime_churn_mrr
    from revenue_lifetime
    left join revenue_latest
        on revenue_lifetime.account_id = revenue_latest.account_id

),

usage_30d as (

    select
        account_id,
        sum(usage_count) as usage_count_30d,
        sum(usage_duration_secs) as usage_duration_secs_30d,
        sum(error_count) as error_count_30d,
        count(distinct feature_name) as active_features_30d,
        max(usage_date) as latest_usage_date
    from {{ ref('int_nefinance_account_feature_usage_daily') }}
    where usage_date >= dateadd(day, -30, current_date)
    group by 1

),

support as (

    select * from {{ ref('int_nefinance_account_support_health') }}

),

churn as (

    select
        account_id,
        max(churn_date) as latest_churn_date,
        count(*) as churn_event_count,
        boolor_agg(is_reactivation) as has_reactivation
    from {{ ref('int_nefinance_churn_events_enriched') }}
    group by 1

),

combined as (

    select
        accounts.account_id,
        accounts.account_name,
        accounts.country,
        accounts.industry,
        accounts.referral_source,
        accounts.plan_tier,
        accounts.seats,
        accounts.seat_band,
        accounts.account_lifecycle_status,
        accounts.signup_date,
        accounts.account_age_days,
        coalesce(revenue.current_mrr, 0) as current_mrr,
        coalesce(revenue.current_arr, 0) as current_arr,
        revenue.latest_revenue_month,
        coalesce(revenue.lifetime_expansion_mrr, 0) as lifetime_expansion_mrr,
        coalesce(revenue.lifetime_contraction_mrr, 0) as lifetime_contraction_mrr,
        coalesce(revenue.lifetime_churn_mrr, 0) as lifetime_churn_mrr,
        coalesce(usage_30d.usage_count_30d, 0) as usage_count_30d,
        coalesce(usage_30d.usage_duration_secs_30d, 0) as usage_duration_secs_30d,
        coalesce(usage_30d.error_count_30d, 0) as error_count_30d,
        coalesce(usage_30d.active_features_30d, 0) as active_features_30d,
        usage_30d.latest_usage_date,
        coalesce(support.ticket_count, 0) as ticket_count,
        coalesce(support.open_ticket_count, 0) as open_ticket_count,
        coalesce(support.high_priority_ticket_count, 0) as high_priority_ticket_count,
        coalesce(support.escalation_count, 0) as escalation_count,
        support.avg_satisfaction_score,
        coalesce(support.support_health_status, 'healthy') as support_health_status,
        churn.latest_churn_date,
        coalesce(churn.churn_event_count, 0) as churn_event_count,
        coalesce(churn.has_reactivation, false) as has_reactivation
    from accounts
    left join revenue
        on accounts.account_id = revenue.account_id
    left join usage_30d
        on accounts.account_id = usage_30d.account_id
    left join support
        on accounts.account_id = support.account_id
    left join churn
        on accounts.account_id = churn.account_id

)

select
    *,
    case
        when account_lifecycle_status = 'churned' then 'churned'
        when open_ticket_count > 0
            or high_priority_ticket_count > 0
            or escalation_count > 0
            or coalesce(avg_satisfaction_score, 5) < 3
            or active_features_30d = 0 then 'at_risk'
        when active_features_30d >= 3 and support_health_status = 'healthy' then 'healthy'
        else 'monitor'
    end as customer_health_status
from combined
