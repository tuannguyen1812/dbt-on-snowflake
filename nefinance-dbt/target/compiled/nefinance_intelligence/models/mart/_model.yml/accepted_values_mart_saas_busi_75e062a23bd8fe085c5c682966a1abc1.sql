
    
    

with all_values as (

    select
        business_performance_status as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.mart_saas_business_performance_monthly
    group by business_performance_status

)

select *
from all_values
where value_field not in (
    'needs_attention','expanding','stable'
)


