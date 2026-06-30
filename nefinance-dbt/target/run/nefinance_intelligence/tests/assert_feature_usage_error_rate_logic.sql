select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
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
      
    ) dbt_internal_test