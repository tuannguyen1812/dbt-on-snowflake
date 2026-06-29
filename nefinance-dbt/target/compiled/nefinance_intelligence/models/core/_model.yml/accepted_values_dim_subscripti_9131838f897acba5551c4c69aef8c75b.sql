
    
    

with all_values as (

    select
        subscription_status as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.dim_subscription
    group by subscription_status

)

select *
from all_values
where value_field not in (
    'active','trial','churned','ended','scheduled'
)


