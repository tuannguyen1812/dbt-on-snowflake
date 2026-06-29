select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ticker
from NEFINANCE_DB.DEV.dim_market_company
where ticker is null



      
    ) dbt_internal_test