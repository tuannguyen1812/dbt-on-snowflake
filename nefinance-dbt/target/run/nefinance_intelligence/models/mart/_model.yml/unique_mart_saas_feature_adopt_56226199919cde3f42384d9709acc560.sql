select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    feature_adoption_month_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.mart_saas_feature_adoption_monthly
where feature_adoption_month_key is not null
group by feature_adoption_month_key
having count(*) > 1



      
    ) dbt_internal_test