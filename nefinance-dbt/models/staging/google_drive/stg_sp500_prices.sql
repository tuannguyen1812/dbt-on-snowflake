-- stg_sp500_prices.sql

    select *

    from {{ source('google_drive', 'SP_500_HISTORICAL_DATA') }}
