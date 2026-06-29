
    
    

with all_values as (

    select
        support_health_status as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.int_nefinance_account_support_health
    group by support_health_status

)

select *
from all_values
where value_field not in (
    'healthy','monitored','at_risk'
)


