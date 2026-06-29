select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select report_date
from NEFINANCE_DB.DEV.stg_short_financials
where report_date is null



      
    ) dbt_internal_test