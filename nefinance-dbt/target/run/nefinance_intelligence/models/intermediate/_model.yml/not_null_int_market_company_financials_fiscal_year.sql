select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select fiscal_year
from NEFINANCE_DB.DEV.int_market_company_financials
where fiscal_year is null



      
    ) dbt_internal_test