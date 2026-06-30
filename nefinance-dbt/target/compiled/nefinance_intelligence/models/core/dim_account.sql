

with accounts as (

    select * from NEFINANCE_DB.PROD.int_nefinance_account_health

)

select
    md5(account_id) as account_key,
    account_id,
    account_name,
    country,
    industry,
    referral_source,
    plan_tier,
    seats,
    seat_band,
    account_lifecycle_status,
    customer_health_status,
    support_health_status,
    signup_date,
    account_age_days,
    latest_usage_date,
    latest_revenue_month,
    latest_churn_date,
    has_reactivation,
    current_timestamp as transformed_at
from accounts