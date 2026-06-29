
  
    

        create or replace transient table NEFINANCE_DB.DEV.dim_date
         as
        (

with source_dates as (

    select cast(signup_date as date) as observed_date
    from NEFINANCE_DB.DEV.stg_nefinance_accounts

    union all

    select cast(start_date as date) as observed_date
    from NEFINANCE_DB.DEV.stg_nefinance_subscriptions

    union all

    select cast(end_date as date) as observed_date
    from NEFINANCE_DB.DEV.stg_nefinance_subscriptions

    union all

    select cast(usage_date as date) as observed_date
    from NEFINANCE_DB.DEV.stg_nefinance_feature_usage

    union all

    select cast(submitted_at as date) as observed_date
    from NEFINANCE_DB.DEV.stg_nefinance_support_tickets

    union all

    select cast(closed_at as date) as observed_date
    from NEFINANCE_DB.DEV.stg_nefinance_support_tickets

    union all

    select cast(churn_date as date) as observed_date
    from NEFINANCE_DB.DEV.stg_nefinance_churn_events

    union all

    select price_date as observed_date
    from NEFINANCE_DB.DEV.stg_sp500_prices

    union all

    select report_date as observed_date
    from NEFINANCE_DB.DEV.stg_short_financials

    union all

    select price_date as observed_date
    from NEFINANCE_DB.DEV.stg_short_financials

    union all

    select published_date as observed_date
    from NEFINANCE_DB.DEV.stg_financial_news

),

bounds as (

    select
        coalesce(min(observed_date), to_date('2000-01-01')) as start_date,
        greatest(
            coalesce(max(observed_date), current_date),
            dateadd(year, 5, current_date)
        ) as end_date
    from source_dates
    where observed_date is not null

),

generated as (

    select seq4() as day_number
    from table(generator(rowcount => 100000))

),

date_spine as (

    select dateadd(day, generated.day_number, bounds.start_date) as date_day
    from generated
    cross join bounds
    where dateadd(day, generated.day_number, bounds.start_date) <= bounds.end_date

)

select
    to_number(to_varchar(date_day, 'YYYYMMDD')) as date_key,
    date_day,
    year(date_day) as calendar_year,
    quarter(date_day) as calendar_quarter,
    month(date_day) as month_number,
    monthname(date_day) as month_name,
    date_trunc('month', date_day) as month_start_date,
    last_day(date_day, 'month') as month_end_date,
    date_trunc('quarter', date_day) as quarter_start_date,
    last_day(date_day, 'quarter') as quarter_end_date,
    weekiso(date_day) as iso_week_number,
    yearofweekiso(date_day) as iso_week_year,
    dayofweekiso(date_day) as iso_day_of_week,
    dayname(date_day) as day_name,
    dayofmonth(date_day) as day_of_month,
    dayofyear(date_day) as day_of_year,
    iff(dayofweekiso(date_day) in (6, 7), true, false) as is_weekend
from date_spine
        );
      
  