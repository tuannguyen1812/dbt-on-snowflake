select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select date
from NEFINANCE_DB.DEV.stg_sp500_prices
where date is null



      
    ) dbt_internal_test