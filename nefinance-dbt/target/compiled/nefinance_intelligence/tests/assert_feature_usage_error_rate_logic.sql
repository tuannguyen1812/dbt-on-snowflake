with usage_daily as (

    select *
    from NEFINANCE_DB.DEV.fct_feature_usage_daily

)

select *
from usage_daily
where (
        usage_count = 0
        and error_rate is not null
    )