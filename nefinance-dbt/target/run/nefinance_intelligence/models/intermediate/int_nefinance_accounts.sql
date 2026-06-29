
  create or replace   view NEFINANCE_DB.DEV.int_nefinance_accounts
  
   as (
    

with accounts as (

    select * from NEFINANCE_DB.DEV.stg_nefinance_accounts

),

renamed as (

    select
        account_id,
        account_name,
        lower(trim(country)) as country,
        lower(trim(industry)) as industry,
        lower(trim(referral_source)) as referral_source,
        lower(trim(plan_tier)) as plan_tier,
        coalesce(seats, 0) as seats,
        coalesce(is_trial, false) as is_trial,
        coalesce(churn_flag, false) as churn_flag,
        cast(signup_date as date) as signup_date,
        record_id,
        loaded_at
    from accounts

),

enriched as (

    select
        account_id,
        account_name,
        country,
        industry,
        referral_source,
        plan_tier,
        seats,
        case
            when seats = 0 then 'no_seats'
            when seats between 1 and 10 then 'small'
            when seats between 11 and 50 then 'mid_market'
            else 'enterprise'
        end as seat_band,
        is_trial,
        churn_flag,
        case
            when churn_flag then 'churned'
            when is_trial then 'trial'
            else 'active'
        end as account_lifecycle_status,
        signup_date,
        datediff(day, signup_date, current_date) as account_age_days,
        record_id,
        loaded_at
    from renamed

)

select * from enriched
  );

