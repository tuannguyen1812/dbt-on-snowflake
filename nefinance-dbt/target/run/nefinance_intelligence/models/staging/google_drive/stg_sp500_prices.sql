
  create or replace   view NEFINANCE_DB.DEV.stg_sp500_prices
  
   as (
    -- stg_sp500_prices.sql

    select *

    from PC_FIVETRAN_DB.GOOGLE_DRIVE.SP_500_HISTORICAL_DATA
  );

