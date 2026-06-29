select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select market_price_day_key
from NEFINANCE_DB.DEV.fct_market_price_daily
where market_price_day_key is null



      
    ) dbt_internal_test