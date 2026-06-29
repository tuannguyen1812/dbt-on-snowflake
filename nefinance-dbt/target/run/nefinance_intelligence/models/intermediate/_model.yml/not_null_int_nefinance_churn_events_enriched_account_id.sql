select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select account_id
from NEFINANCE_DB.DEV.int_nefinance_churn_events_enriched
where account_id is null



      
    ) dbt_internal_test