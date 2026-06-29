
    
    

select
    account_id as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.int_nefinance_account_health
where account_id is not null
group by account_id
having count(*) > 1


