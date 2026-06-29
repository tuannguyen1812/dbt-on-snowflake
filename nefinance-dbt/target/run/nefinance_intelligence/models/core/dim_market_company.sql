
  create or replace   view NEFINANCE_DB.DEV.dim_market_company
  
   as (
    

with financials as (

    select
        ticker,
        cik,
        fiscal_year,
        report_date,
        loaded_at
    from NEFINANCE_DB.DEV.int_market_company_financials

),

prices as (

    select
        ticker,
        null as cik,
        null as fiscal_year,
        null as report_date,
        fivetran_synced_at as loaded_at
    from NEFINANCE_DB.DEV.int_market_prices_daily

),

combined as (

    select * from financials
    union all
    select * from prices

),

companies as (

    select
        ticker,
        max(cik) as cik,
        min(fiscal_year) as first_fiscal_year,
        max(fiscal_year) as latest_fiscal_year,
        max(report_date) as latest_report_date,
        max(loaded_at) as latest_loaded_at
    from combined
    where ticker is not null
    group by 1

)

select
    md5(ticker) as company_key,
    ticker,
    cik,
    first_fiscal_year,
    latest_fiscal_year,
    latest_report_date,
    latest_loaded_at,
    current_timestamp as transformed_at
from companies
  );

