select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        customer_health_status as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.dim_account
    group by customer_health_status

)

select *
from all_values
where value_field not in (
    'healthy','monitor','at_risk','churned'
)



      
    ) dbt_internal_test