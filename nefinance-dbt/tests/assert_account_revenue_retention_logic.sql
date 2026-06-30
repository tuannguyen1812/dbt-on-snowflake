with revenue as (

    select *
    from {{ ref('fct_account_revenue_monthly') }}

)

select *
from revenue
where retained_mrr is distinct from starting_mrr + expansion_mrr - contraction_mrr - churn_mrr
    or (
        starting_mrr = 0
        and (
            net_revenue_retention_rate is not null
            or gross_revenue_retention_rate is not null
        )
    )
    or (
        starting_mrr != 0
        and (
            net_revenue_retention_rate is null
            or gross_revenue_retention_rate is null
            or abs(
                net_revenue_retention_rate
                - {{ safe_divide('retained_mrr', 'starting_mrr') }}
            ) > 0.000001
            or abs(
                gross_revenue_retention_rate
                - {{ safe_divide('(starting_mrr - contraction_mrr - churn_mrr)', 'starting_mrr') }}
            ) > 0.000001
        )
    )
