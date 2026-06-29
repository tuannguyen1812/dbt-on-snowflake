select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ticker
from NEFINANCE_DB.DEV.int_market_company_financials
where ticker is null



      
    ) dbt_internal_test