
  create or replace   view NEFINANCE_DB.DEV.stg_sp500_pricces
  
   as (
    -- stg_sp500_prices.sql

with source as (

    select *

    from PC_FIVETRAN_DB.GOOGLE_DRIVE.SP_500_HISTORICAL_DATA

)

select
    ticker,
    date,
    close
from source
  );

