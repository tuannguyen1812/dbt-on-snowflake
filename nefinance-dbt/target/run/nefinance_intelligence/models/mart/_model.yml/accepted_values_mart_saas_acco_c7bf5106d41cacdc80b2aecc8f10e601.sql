select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

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



      
    ) dbt_internal_test