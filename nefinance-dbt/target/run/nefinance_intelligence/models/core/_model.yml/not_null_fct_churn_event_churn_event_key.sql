select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select churn_event_key
from NEFINANCE_DB.DEV.fct_churn_event
where churn_event_key is null



      
    ) dbt_internal_test