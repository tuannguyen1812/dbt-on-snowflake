
    
    

with child as (
    select price_date_key as from_field
    from NEFINANCE_DB.DEV.fct_market_price_daily
    where price_date_key is not null
),

parent as (
    select date_key as to_field
    from NEFINANCE_DB.DEV.dim_date
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


