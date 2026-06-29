
    
    

with child as (
    select company_key as from_field
    from NEFINANCE_DB.DEV.fct_company_financials_yearly
    where company_key is not null
),

parent as (
    select company_key as to_field
    from NEFINANCE_DB.DEV.dim_market_company
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


