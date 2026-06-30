
  
    

        create or replace transient table NEFINANCE_DB.PROD.fct_churn_event
         as
        (select * from (
              

with churn_events as (

    select * from NEFINANCE_DB.PROD.int_nefinance_churn_events_enriched
    

),

accounts as (

    select account_key, account_id
    from NEFINANCE_DB.PROD.dim_account

)

select
    md5(churn_events.churn_event_id) as churn_event_key,
    accounts.account_key,
   to_number(to_varchar(churn_events.churn_date, 'YYYYMMDD')) as churn_date_key,
    churn_events.churn_event_id,
    churn_events.account_id,
    churn_events.churn_date,
    churn_events.churn_month,
    churn_events.reason_code,
    churn_events.reason_category,
    churn_events.preceding_upgrade_flag,
    churn_events.preceding_downgrade_flag,
    churn_events.is_reactivation,
    churn_events.feedback_text,
    churn_events.refund_amount_usd,
    churn_events.record_id,
    churn_events.loaded_at as latest_loaded_at,
    current_timestamp as transformed_at
from churn_events
left join accounts
    on churn_events.account_id = accounts.account_id
              ) order by (churn_date, account_id)
        );
      alter  table NEFINANCE_DB.PROD.fct_churn_event cluster by (churn_date, account_id);
  