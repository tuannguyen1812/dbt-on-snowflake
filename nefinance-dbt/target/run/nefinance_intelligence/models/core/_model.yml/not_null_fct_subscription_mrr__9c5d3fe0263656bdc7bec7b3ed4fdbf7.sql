select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select subscription_mrr_movement_key
from NEFINANCE_DB.DEV.fct_subscription_mrr_movements
where subscription_mrr_movement_key is null



      
    ) dbt_internal_test