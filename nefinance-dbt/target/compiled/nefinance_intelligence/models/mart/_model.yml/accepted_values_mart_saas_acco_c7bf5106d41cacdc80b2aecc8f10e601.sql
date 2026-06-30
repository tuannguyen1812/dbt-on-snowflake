
    
    

with all_values as (

    select
        account_action_status as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.mart_saas_account_health
    group by account_action_status

)

select *
from all_values
where value_field not in (
    'churned','at_risk','growth_opportunity','healthy'
)


