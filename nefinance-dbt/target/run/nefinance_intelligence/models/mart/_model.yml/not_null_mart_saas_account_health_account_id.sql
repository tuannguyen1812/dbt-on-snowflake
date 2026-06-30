select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select account_id
from NEFINANCE_DB.DEV.mart_saas_account_health
where account_id is null



      
    ) dbt_internal_test