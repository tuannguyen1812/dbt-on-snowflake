with watchlist as (

    select *
    from NEFINANCE_DB.DEV.mart_market_watchlist_daily

),

expected as (

    select
        *,
        case
            when daily_return_pct >= 0.03
                and coalesce(market_sentiment_score, 0) >= 0 then 'bullish_watch'
            when daily_return_pct <= -0.03
                or coalesce(market_sentiment_score, 0) < -0.25 then 'risk_watch'
            when pct_of_52w_high >= 0.95 then 'near_52w_high'
            when pct_of_52w_high <= 0.75 then 'below_52w_high'
            else 'normal'
        end as expected_market_watch_signal
    from watchlist

)

select *
from expected
where market_watch_signal is distinct from expected_market_watch_signal