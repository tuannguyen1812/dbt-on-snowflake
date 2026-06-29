
    
    

select
    churn_event_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.fct_churn_event
where churn_event_key is not null
group by churn_event_key
having count(*) > 1


