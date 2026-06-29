select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    subscription_mrr_movement_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.fct_subscription_mrr_movements
where subscription_mrr_movement_key is not null
group by subscription_mrr_movement_key
having count(*) > 1



      
    ) dbt_internal_test