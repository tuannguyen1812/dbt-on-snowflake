
  create or replace   view NEFINANCE_DB.DEV.int_nefinance_account_support_health
  
   as (
    

with tickets as (

    select * from NEFINANCE_DB.DEV.stg_nefinance_support_tickets

),

ticket_cleaned as (

    select
        ticket_id,
        account_id,
        lower(trim(priority)) as priority,
        cast(submitted_at as timestamp_ntz(9)) as submitted_at,
        cast(closed_at as timestamp_ntz(9)) as closed_at,
        coalesce(resolution_time_hours, 0) as resolution_time_hours,
        coalesce(first_response_time_minutes, 0) as first_response_time_minutes,
        coalesce(escalation_flag, false) as escalation_flag,
        satisfaction_score,
        loaded_at
    from tickets

),

account_rollup as (

    select
        account_id,
        count(*) as ticket_count,
        count_if(closed_at is null) as open_ticket_count,
        count_if(priority in ('high', 'urgent', 'critical')) as high_priority_ticket_count,
        count_if(escalation_flag) as escalation_count,
        avg(resolution_time_hours) as avg_resolution_time_hours,
        avg(first_response_time_minutes) as avg_first_response_time_minutes,
        avg(satisfaction_score) as avg_satisfaction_score,
        max(submitted_at) as latest_ticket_submitted_at,
        max(closed_at) as latest_ticket_closed_at,
        max(loaded_at) as latest_loaded_at
    from ticket_cleaned
    group by 1

),

scored as (

    select
        account_id,
        ticket_count,
        open_ticket_count,
        high_priority_ticket_count,
        escalation_count,
        avg_resolution_time_hours,
        avg_first_response_time_minutes,
        avg_satisfaction_score,
        latest_ticket_submitted_at,
        latest_ticket_closed_at,
        case
            when open_ticket_count > 0
                or high_priority_ticket_count > 0
                or escalation_count > 0
                or avg_satisfaction_score < 3 then 'at_risk'
            when ticket_count > 0 then 'monitored'
            else 'healthy'
        end as support_health_status,
        latest_loaded_at
    from account_rollup

)

select * from scored
  );

