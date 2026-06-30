select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        market_tone_signal as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.mart_market_news_sentiment_daily
    group by market_tone_signal

)

select *
from all_values
where value_field not in (
    'positive_market_tone','neutral_market_tone','negative_market_tone'
)



      
    ) dbt_internal_test