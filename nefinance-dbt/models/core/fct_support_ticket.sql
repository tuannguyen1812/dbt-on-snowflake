{{ config(
    materialized = 'incremental',
    unique_key = 'ticket_key',
    incremental_strategy = 'merge',
    on_schema_change = 'sync_all_columns',
    cluster_by = ['submitted_date', 'account_id']
) }}

with tickets as (

    select * from {{ ref('stg_nefinance_support_tickets') }}
    {% if is_incremental() %}
        where loaded_at >= (
            select coalesce(
                max(latest_loaded_at),
                to_timestamp_tz('1900-01-01 00:00:00 +00:00')
            )
            from {{ this }}
        )
    {% endif %}

),

accounts as (

    select account_key, account_id
    from {{ ref('dim_account') }}

)

select
    md5(tickets.ticket_id) as ticket_key,
    accounts.account_key,
    to_number(to_varchar(cast(tickets.submitted_at as date), 'YYYYMMDD')) as submitted_date_key,
    to_number(to_varchar(cast(tickets.closed_at as date), 'YYYYMMDD')) as closed_date_key,
    tickets.ticket_id,
    tickets.account_id,
    lower(trim(tickets.priority)) as priority,
    cast(tickets.submitted_at as timestamp_ntz(9)) as submitted_at,
    cast(tickets.submitted_at as date) as submitted_date,
    cast(tickets.closed_at as timestamp_ntz(9)) as closed_at,
    cast(tickets.closed_at as date) as closed_date,
    iff(tickets.closed_at is null, true, false) as is_open,
    coalesce(tickets.resolution_time_hours, 0) as resolution_time_hours,
    coalesce(tickets.first_response_time_minutes, 0) as first_response_time_minutes,
    coalesce(tickets.escalation_flag, false) as escalation_flag,
    tickets.satisfaction_score,
    tickets.record_id,
    tickets.loaded_at as latest_loaded_at,
    current_timestamp as transformed_at
from tickets
left join accounts
    on tickets.account_id = accounts.account_id
