
    
    

select
    feature_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.dim_feature
where feature_key is not null
group by feature_key
having count(*) > 1


