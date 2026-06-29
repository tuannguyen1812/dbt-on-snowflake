

with accounts as (

    select * from NEFINANCE_DB.DEV.dim_account

),

latest_revenue as (

    select *
    from NEFINANCE_DB.DEV.fct_account_revenue_monthly
    qualify row_number() over (
        partition by account_id
        order by revenue_month desc
    ) = 1

),

usage_30d as (

    select
        account_id,
        count(distinct feature_name) as active_features_30d,
        sum(usage_count) as usage_count_30d,
        sum(usage_duration_secs) as usage_duration_secs_30d,
        sum(error_count) as error_count_30d,
        max(usage_date) as latest_usage_date
    from NEFINANCE_DB.DEV.fct_feature_usage_daily
    where usage_date >= dateadd(day, -30, current_date)
    group by 1

),

support as (

    select
        account_id,
        count(*) as lifetime_ticket_count,
        count_if(is_open) as open_ticket_count,
        count_if(escalation_flag) as escalated_ticket_count,
        avg(satisfaction_score) as avg_satisfaction_score,
        max(submitted_at) as latest_ticket_submitted_at
    from NEFINANCE_DB.DEV.fct_support_ticket
    group by 1

),

churn as (

    select
        account_id,
        max(churn_date) as latest_churn_date,
        count(*) as churn_event_count,
        count_if(is_reactivation) as reactivation_count,
        sum(refund_amount_usd) as refund_amount_usd
    from NEFINANCE_DB.DEV.fct_churn_event
    group by 1

)

select
    accounts.account_key,
    accounts.account_id,
    accounts.account_name,
    accounts.country,
    accounts.industry,
    accounts.referral_source,
    accounts.plan_tier,
    accounts.seats,
    accounts.seat_band,
    accounts.account_lifecycle_status,
    accounts.customer_health_status,
    accounts.support_health_status,
    accounts.signup_date,
    accounts.account_age_days,
    latest_revenue.revenue_month as latest_revenue_month,
    coalesce(latest_revenue.ending_mrr, 0) as current_mrr,
    coalesce(latest_revenue.ending_arr, 0) as current_arr,
    coalesce(latest_revenue.expansion_mrr, 0) as latest_expansion_mrr,
    coalesce(latest_revenue.contraction_mrr, 0) as latest_contraction_mrr,
    coalesce(latest_revenue.churn_mrr, 0) as latest_churn_mrr,
    coalesce(usage_30d.active_features_30d, 0) as active_features_30d,
    coalesce(usage_30d.usage_count_30d, 0) as usage_count_30d,
    coalesce(usage_30d.usage_duration_secs_30d, 0) as usage_duration_secs_30d,
    coalesce(usage_30d.error_count_30d, 0) as error_count_30d,
    usage_30d.latest_usage_date,
    coalesce(support.lifetime_ticket_count, 0) as lifetime_ticket_count,
    coalesce(support.open_ticket_count, 0) as open_ticket_count,
    coalesce(support.escalated_ticket_count, 0) as escalated_ticket_count,
    support.avg_satisfaction_score,
    support.latest_ticket_submitted_at,
    churn.latest_churn_date,
    coalesce(churn.churn_event_count, 0) as churn_event_count,
    coalesce(churn.reactivation_count, 0) as reactivation_count,
    coalesce(churn.refund_amount_usd, 0) as refund_amount_usd,
    case
        when accounts.account_lifecycle_status = 'churned' then 100
        else
            iff(coalesce(usage_30d.active_features_30d, 0) = 0, 25, 0)
            + iff(coalesce(support.open_ticket_count, 0) > 0, 20, 0)
            + iff(coalesce(support.escalated_ticket_count, 0) > 0, 20, 0)
            + iff(coalesce(support.avg_satisfaction_score, 5) < 3, 20, 0)
            + iff(coalesce(latest_revenue.contraction_mrr, 0) > 0, 15, 0)
    end as customer_risk_score,
    case
        when accounts.account_lifecycle_status = 'churned' then 'churned'
        when coalesce(usage_30d.active_features_30d, 0) = 0
            or coalesce(support.open_ticket_count, 0) > 0
            or coalesce(support.escalated_ticket_count, 0) > 0
            or coalesce(support.avg_satisfaction_score, 5) < 3
            or coalesce(latest_revenue.contraction_mrr, 0) > 0 then 'at_risk'
        when coalesce(latest_revenue.expansion_mrr, 0) > 0
            and coalesce(usage_30d.active_features_30d, 0) >= 3 then 'growth_opportunity'
        else 'healthy'
    end as account_action_status,
    current_timestamp as transformed_at
from accounts
left join latest_revenue
    on accounts.account_id = latest_revenue.account_id
left join usage_30d
    on accounts.account_id = usage_30d.account_id
left join support
    on accounts.account_id = support.account_id
left join churn
    on accounts.account_id = churn.account_id