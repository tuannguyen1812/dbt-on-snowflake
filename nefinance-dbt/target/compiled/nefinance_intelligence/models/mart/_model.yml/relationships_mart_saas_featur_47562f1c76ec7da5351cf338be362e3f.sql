
    
    

with child as (
    select feature_key as from_field
    from NEFINANCE_DB.DEV.mart_saas_feature_adoption_monthly
    where feature_key is not null
),

parent as (
    select feature_key as to_field
    from NEFINANCE_DB.DEV.dim_feature
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


