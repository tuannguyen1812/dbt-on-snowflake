
    
    

with all_values as (

    select
        customer_health_status as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.int_nefinance_account_health
    group by customer_health_status

)

select *
from all_values
where value_field not in (
    'healthy','monitor','at_risk','churned'
)


