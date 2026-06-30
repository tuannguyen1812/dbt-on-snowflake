
    
    

with all_values as (

    select
        market_watch_signal as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.mart_market_watchlist_daily
    group by market_watch_signal

)

select *
from all_values
where value_field not in (
    'bullish_watch','risk_watch','near_52w_high','below_52w_high','normal'
)


