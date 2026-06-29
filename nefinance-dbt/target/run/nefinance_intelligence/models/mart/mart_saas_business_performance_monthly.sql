
  
    

        create or replace transient table NEFINANCE_DB.DEV.mart_saas_business_performance_monthly
         as
        (select * from (
              

with revenue as (

    select * from NEFINANCE_DB.DEV.fct_account_revenue_monthly
    

),

revenue_monthly as (

    select
        revenue.revenue_month as performance_month,
        sum(revenue.starting_mrr) as starting_mrr,
        sum(revenue.new_mrr) as new_mrr,
        sum(revenue.expansion_mrr) as expansion_mrr,
        sum(revenue.contraction_mrr) as contraction_mrr,
        sum(revenue.churn_mrr) as churn_mrr,
        sum(revenue.retained_mrr) as retained_mrr,
        sum(revenue.net_mrr_change) as net_mrr_change,
        sum(revenue.ending_mrr) as ending_mrr,
        sum(revenue.ending_arr) as ending_arr,
        sum(revenue.ending_seats) as ending_seats,
        count(distinct revenue.account_id) as revenue_account_count,
        count(distinct iff(revenue.ending_mrr > 0, revenue.account_id, null)) as paying_account_count,
        count(distinct iff(revenue.new_mrr > 0, revenue.account_id, null)) as new_revenue_account_count,
        count(distinct iff(revenue.expansion_mrr > 0, revenue.account_id, null)) as expansion_account_count,
        count(distinct iff(revenue.contraction_mrr > 0, revenue.account_id, null)) as contraction_account_count,
        count(distinct iff(revenue.churn_mrr > 0, revenue.account_id, null)) as revenue_churn_account_count,
        max(revenue.latest_loaded_at) as latest_loaded_at
    from revenue
    group by 1

),

usage_monthly as (

    select
        date_trunc('month', usage_date) as performance_month,
        count(distinct account_id) as active_usage_account_count,
        count(distinct feature_name) as active_feature_count,
        sum(usage_count) as usage_count,
        sum(usage_duration_secs) as usage_duration_secs,
        sum(error_count) as error_count
    from NEFINANCE_DB.DEV.fct_feature_usage_daily
    
    group by 1

),

support_monthly as (

    select
        date_trunc('month', submitted_date) as performance_month,
        count(*) as submitted_ticket_count,
        count_if(is_open) as open_ticket_count,
        count_if(escalation_flag) as escalated_ticket_count,
        avg(resolution_time_hours) as avg_resolution_time_hours,
        avg(first_response_time_minutes) as avg_first_response_time_minutes,
        avg(satisfaction_score) as avg_satisfaction_score
    from NEFINANCE_DB.DEV.fct_support_ticket
    
    group by 1

),

churn_monthly as (

    select
        churn_month as performance_month,
        count(*) as churn_event_count,
        count_if(is_reactivation) as reactivation_count,
        sum(refund_amount_usd) as refund_amount_usd
    from NEFINANCE_DB.DEV.fct_churn_event
    
    group by 1

)

select
    md5(to_varchar(revenue_monthly.performance_month, 'YYYY-MM-DD')) as business_performance_month_key,
    to_number(to_varchar(revenue_monthly.performance_month, 'YYYYMMDD')) as performance_month_date_key,
    revenue_monthly.performance_month,
    revenue_monthly.starting_mrr,
    revenue_monthly.new_mrr,
    revenue_monthly.expansion_mrr,
    revenue_monthly.contraction_mrr,
    revenue_monthly.churn_mrr,
    revenue_monthly.retained_mrr,
    revenue_monthly.net_mrr_change,
    revenue_monthly.ending_mrr,
    revenue_monthly.ending_arr,
    revenue_monthly.ending_seats,
    case
        when revenue_monthly.starting_mrr = 0 then null
        else revenue_monthly.retained_mrr / nullif(revenue_monthly.starting_mrr, 0)
    end as net_revenue_retention_rate,
    case
        when revenue_monthly.starting_mrr = 0 then null
        else (
            revenue_monthly.starting_mrr
            - revenue_monthly.contraction_mrr
            - revenue_monthly.churn_mrr
            ) / nullif(revenue_monthly.starting_mrr, 0)
    end as gross_revenue_retention_rate,
    revenue_monthly.revenue_account_count,
    revenue_monthly.paying_account_count,
    revenue_monthly.new_revenue_account_count,
    revenue_monthly.expansion_account_count,
    revenue_monthly.contraction_account_count,
    revenue_monthly.revenue_churn_account_count,
    case
        when revenue_monthly.paying_account_count = 0 then null
        else revenue_monthly.ending_mrr / nullif(revenue_monthly.paying_account_count, 0)
    end as average_mrr_per_paying_account,
    case
        when revenue_monthly.ending_seats = 0 then null
        else revenue_monthly.ending_mrr / nullif(revenue_monthly.ending_seats, 0)
    end as average_mrr_per_seat,
    coalesce(usage_monthly.active_usage_account_count, 0) as active_usage_account_count,
    coalesce(usage_monthly.active_feature_count, 0) as active_feature_count,
    coalesce(usage_monthly.usage_count, 0) as usage_count,
    coalesce(usage_monthly.usage_duration_secs, 0) as usage_duration_secs,
    coalesce(usage_monthly.error_count, 0) as error_count,
    case
        when coalesce(usage_monthly.usage_count, 0) = 0 then null
        else usage_monthly.error_count / nullif(usage_monthly.usage_count, 0)
    end as product_error_rate,
    coalesce(support_monthly.submitted_ticket_count, 0) as submitted_ticket_count,
    coalesce(support_monthly.open_ticket_count, 0) as open_ticket_count,
    coalesce(support_monthly.escalated_ticket_count, 0) as escalated_ticket_count,
    support_monthly.avg_resolution_time_hours,
    support_monthly.avg_first_response_time_minutes,
    support_monthly.avg_satisfaction_score,
    coalesce(churn_monthly.churn_event_count, 0) as churn_event_count,
    coalesce(churn_monthly.reactivation_count, 0) as reactivation_count,
    coalesce(churn_monthly.refund_amount_usd, 0) as refund_amount_usd,
    case
        when revenue_monthly.churn_mrr > 0
            or coalesce(support_monthly.escalated_ticket_count, 0) > 0
            or (
                revenue_monthly.starting_mrr > 0
                and revenue_monthly.retained_mrr / nullif(revenue_monthly.starting_mrr, 0) < 1
            ) then 'needs_attention'
        when revenue_monthly.expansion_mrr > revenue_monthly.contraction_mrr then 'expanding'
        else 'stable'
    end as business_performance_status,
    revenue_monthly.latest_loaded_at,
    current_timestamp as transformed_at
from revenue_monthly
left join usage_monthly
    on revenue_monthly.performance_month = usage_monthly.performance_month
left join support_monthly
    on revenue_monthly.performance_month = support_monthly.performance_month
left join churn_monthly
    on revenue_monthly.performance_month = churn_monthly.performance_month
              ) order by (performance_month)
        );
      alter  table NEFINANCE_DB.DEV.mart_saas_business_performance_monthly cluster by (performance_month);
  