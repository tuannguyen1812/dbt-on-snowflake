
    
    

select
    feature_name as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.dim_feature
where feature_name is not null
group by feature_name
having count(*) > 1


