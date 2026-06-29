select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select company_financial_year_key
from NEFINANCE_DB.DEV.int_market_company_financials
where company_financial_year_key is null



      
    ) dbt_internal_test