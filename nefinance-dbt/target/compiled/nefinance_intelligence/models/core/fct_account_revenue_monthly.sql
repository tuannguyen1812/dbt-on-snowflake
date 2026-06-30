

with revenue as (

    select * from NEFINANCE_DB.PROD.int_nefinance_account_revenue_monthly
    

),

accounts as (

    select account_key, account_id
    from NEFINANCE_DB.PROD.dim_account

)

select
    revenue.account_revenue_month_key,
    accounts.account_key,
    to_number(to_varchar(revenue.revenue_month, 'YYYYMMDD')) as revenue_month_date_key,
    revenue.account_id,
    revenue.revenue_month,
    revenue.subscription_events,
    revenue.starting_mrr,
    revenue.new_mrr,
    revenue.expansion_mrr,
    revenue.contraction_mrr,
    revenue.churn_mrr,
    revenue.net_mrr_change,
    revenue.ending_mrr,
    revenue.ending_arr,
    revenue.ending_seats,
    revenue.new_subscription_count,
    revenue.expansion_count,
    revenue.contraction_count,
    revenue.churn_count,
    revenue.trial_subscription_count,
    revenue.starting_mrr + revenue.expansion_mrr - revenue.contraction_mrr - revenue.churn_mrr as retained_mrr,
    ((revenue.starting_mrr + revenue.expansion_mrr - revenue.contraction_mrr - revenue.churn_mrr) / nullif(revenue.starting_mrr, 0)) as net_revenue_retention_rate,
    ((revenue.starting_mrr - revenue.contraction_mrr - revenue.churn_mrr) / nullif(revenue.starting_mrr, 0)) as gross_revenue_retention_rate,
    revenue.latest_loaded_at,
    current_timestamp as transformed_at
from revenue
left join accounts
    on revenue.account_id = accounts.account_id