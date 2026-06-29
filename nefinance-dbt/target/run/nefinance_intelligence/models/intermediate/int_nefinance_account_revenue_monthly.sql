
  create or replace   view NEFINANCE_DB.DEV.int_nefinance_account_revenue_monthly
  
   as (
    

with movements as (

    select * from NEFINANCE_DB.DEV.int_nefinance_subscription_mrr_movements

),

monthly as (

    select
        account_id,
        movement_month as revenue_month,
        count(distinct subscription_id) as subscription_events,
        sum(new_mrr) as new_mrr,
        sum(expansion_mrr) as expansion_mrr,
        sum(contraction_mrr) as contraction_mrr,
        sum(churn_mrr) as churn_mrr,
        sum(mrr_delta) as net_mrr_change,
        sum(mrr_amount) as ending_mrr,
        sum(arr_amount) as ending_arr,
        sum(seats) as ending_seats,
        count_if(mrr_movement_type = 'new') as new_subscription_count,
        count_if(mrr_movement_type = 'expansion') as expansion_count,
        count_if(mrr_movement_type = 'contraction') as contraction_count,
        count_if(mrr_movement_type = 'churn') as churn_count,
        count_if(is_trial) as trial_subscription_count,
        max(loaded_at) as latest_loaded_at
    from movements
    group by 1, 2

),

with_starting as (

    select
        account_id,
        revenue_month,
        subscription_events,
        coalesce(lag(ending_mrr) over (
            partition by account_id
            order by revenue_month
        ), 0) as starting_mrr,
        new_mrr,
        expansion_mrr,
        contraction_mrr,
        churn_mrr,
        net_mrr_change,
        ending_mrr,
        ending_arr,
        ending_seats,
        new_subscription_count,
        expansion_count,
        contraction_count,
        churn_count,
        trial_subscription_count,
        latest_loaded_at
    from monthly

)

select
    concat(account_id, '|', to_varchar(revenue_month, 'YYYY-MM-DD')) as account_revenue_month_key,
    *
from with_starting
  );

