
  create or replace   view NEFINANCE_DB.PROD.stg_nefinance_support_tickets
  
   as (
    

select

    ticket_id,

    account_id,

    priority,

    submitted_at,

    closed_at,

    resolution_time_hours,

    first_response_time_minutes,

    escalation_flag,

    try_to_number(satisfaction_score) as satisfaction_score,

    ctid_fivetran_id as record_id,

    _fivetran_synced as loaded_at

from PC_FIVETRAN_DB.NEFINANCE_POSTGRES_PUBLIC.NEFINANCE_SUPPORT_TICKETS

where not coalesce(_fivetran_deleted,false)
  );

