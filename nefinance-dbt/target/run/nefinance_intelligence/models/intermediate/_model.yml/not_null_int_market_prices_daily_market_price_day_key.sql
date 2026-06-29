select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select market_price_day_key
from NEFINANCE_DB.DEV.int_market_prices_daily
where market_price_day_key is null



      
    ) dbt_internal_test