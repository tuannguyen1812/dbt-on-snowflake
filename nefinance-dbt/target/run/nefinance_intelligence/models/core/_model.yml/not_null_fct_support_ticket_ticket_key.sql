select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ticket_key
from NEFINANCE_DB.DEV.fct_support_ticket
where ticket_key is null



      
    ) dbt_internal_test