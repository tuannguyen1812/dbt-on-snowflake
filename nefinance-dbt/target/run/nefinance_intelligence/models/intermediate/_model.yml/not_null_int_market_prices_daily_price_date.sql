select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select price_date
from NEFINANCE_DB.DEV.int_market_prices_daily
where price_date is null



      
    ) dbt_internal_test