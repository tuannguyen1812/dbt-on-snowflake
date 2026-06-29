
    
    

select
    churn_event_id as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.int_nefinance_churn_events_enriched
where churn_event_id is not null
group by churn_event_id
having count(*) > 1


