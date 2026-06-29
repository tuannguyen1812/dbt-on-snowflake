
    
    

with all_values as (

    select
        sentiment as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.int_market_news_sentiment
    group by sentiment

)

select *
from all_values
where value_field not in (
    'Positive','Neutral','Negative'
)


