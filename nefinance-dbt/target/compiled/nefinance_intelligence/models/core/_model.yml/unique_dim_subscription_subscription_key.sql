
    
    

select
    subscription_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.dim_subscription
where subscription_key is not null
group by subscription_key
having count(*) > 1


