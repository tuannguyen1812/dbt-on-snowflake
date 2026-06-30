select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        watch_status as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.mart_market_ticker_snapshot
    group by watch_status

)

select *
from all_values
where value_field not in (
    'risk_watch','momentum_watch','near_high','normal'
)



      
    ) dbt_internal_test