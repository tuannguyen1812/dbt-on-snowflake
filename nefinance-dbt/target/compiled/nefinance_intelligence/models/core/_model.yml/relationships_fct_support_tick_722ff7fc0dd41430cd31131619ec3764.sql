
    
    

with child as (
    select account_key as from_field
    from NEFINANCE_DB.DEV.fct_support_ticket
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


