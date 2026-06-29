
    
    

select
    usage_id as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.stg_nefinance_feature_usage
where usage_id is not null
group by usage_id
having count(*) > 1


