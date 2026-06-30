select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with child as (
    select account_key as from_field
    from NEFINANCE_DB.DEV.mart_saas_account_health
    where account_key is not null
),

parent as (
    select account_key as to_field
    from NEFINANCE_DB.DEV.dim_account
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



      
    ) dbt_internal_test