
    
    

with all_values as (

    select
        feature_adoption_status as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.mart_saas_feature_adoption_monthly
    group by feature_adoption_status

)

select *
from all_values
where value_field not in (
    'scaled_adoption','quality_watch','low_adoption','steady'
)


