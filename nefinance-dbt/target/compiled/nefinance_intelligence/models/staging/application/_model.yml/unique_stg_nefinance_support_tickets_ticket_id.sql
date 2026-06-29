
    
    

select
    ticket_id as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.stg_nefinance_support_tickets
where ticket_id is not null
group by ticket_id
having count(*) > 1


