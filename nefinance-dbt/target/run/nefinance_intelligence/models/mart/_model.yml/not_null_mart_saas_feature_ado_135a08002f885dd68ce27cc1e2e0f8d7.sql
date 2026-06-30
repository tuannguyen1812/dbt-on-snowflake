select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select feature_adoption_month_key
from NEFINANCE_DB.DEV.mart_saas_feature_adoption_monthly
where feature_adoption_month_key is null



      
    ) dbt_internal_test