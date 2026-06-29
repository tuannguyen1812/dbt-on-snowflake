-- stg_sp500_prices.sql
with source as (
    select _line as source_line_number, 
            cast(_fivetran_synced as timestamp_tz(9)) as fivetran_synced_at,
             cast(ticker as varchar(256)) as ticker,
             Date  as price_date,
        cast(open as float) as open_price,
        cast(high as float) as high_price,
        cast(low as float) as low_price,
        cast(close as float) as close_price,
        cast(adj_close as float) as adjusted_close_price,
        cast(volume as number(38, 0)) as volume
    from {{ source('google_drive', 'SP_500_HISTORICAL_DATA') }}
) , 
deduplicated as (

    select *
    from source
    qualify row_number() over (
        partition by ticker, price_date 
        order by fivetran_synced_at desc, source_line_number desc
    ) = 1

)

select * from deduplicated
