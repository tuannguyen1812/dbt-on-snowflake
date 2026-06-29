select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select cik
from NEFINANCE_DB.DEV.stg_short_financials
where cik is null



      
    ) dbt_internal_test