select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select company_key
from NEFINANCE_DB.DEV.dim_market_company
where company_key is null



      
    ) dbt_internal_test