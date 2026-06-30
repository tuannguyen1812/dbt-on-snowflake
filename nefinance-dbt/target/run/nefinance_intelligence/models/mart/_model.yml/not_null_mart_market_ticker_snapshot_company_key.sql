select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select company_key
from NEFINANCE_DB.DEV.mart_market_ticker_snapshot
where company_key is null



      
    ) dbt_internal_test