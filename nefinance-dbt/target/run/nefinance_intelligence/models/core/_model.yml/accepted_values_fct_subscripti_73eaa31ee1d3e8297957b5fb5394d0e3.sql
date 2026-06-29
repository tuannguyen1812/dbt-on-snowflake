select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        mrr_movement_type as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.fct_subscription_mrr_movements
    group by mrr_movement_type

)

select *
from all_values
where value_field not in (
    'new','expansion','contraction','churn','renewal','trial'
)



      
    ) dbt_internal_test