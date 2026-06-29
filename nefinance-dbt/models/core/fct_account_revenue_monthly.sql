{{ config(
    materialized = 'incremental',
    unique_key = 'account_revenue_month_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns',
    cluster_by = ['revenue_month', 'account_id']
) }}

with revenue as (

    select * from {{ ref('int_nefinance_account_revenue_monthly') }}
    {% if is_incremental() %}
        where revenue_month >= (
            select dateadd(month, -2, coalesce(max(revenue_month), to_date('1900-01-01')))
            from {{ this }}
        )
    {% endif %}

),

accounts as (

    select account_key, account_id
    from {{ ref('dim_account') }}

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
    case
        when revenue.starting_mrr = 0 then null
        else (
            revenue.starting_mrr
            + revenue.expansion_mrr
            - revenue.contraction_mrr
            - revenue.churn_mrr
        ) / revenue.starting_mrr
    end as net_revenue_retention_rate,
    case
        when revenue.starting_mrr = 0 then null
        else (
            revenue.starting_mrr
            - revenue.contraction_mrr
            - revenue.churn_mrr
        ) / revenue.starting_mrr
    end as gross_revenue_retention_rate,
    revenue.latest_loaded_at,
    current_timestamp as transformed_at
from revenue
left join accounts
    on revenue.account_id = accounts.account_id
