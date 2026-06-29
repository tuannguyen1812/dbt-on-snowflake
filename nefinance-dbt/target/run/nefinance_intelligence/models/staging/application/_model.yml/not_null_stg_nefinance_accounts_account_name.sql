select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select account_name
from NEFINANCE_DB.DEV.stg_nefinance_accounts
where account_name is null



      
    ) dbt_internal_test