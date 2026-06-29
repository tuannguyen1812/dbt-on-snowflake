select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        reason_category as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.fct_churn_event
    group by reason_category

)

select *
from all_values
where value_field not in (
    'commercial','product','service','adoption','other'
)



      
    ) dbt_internal_test