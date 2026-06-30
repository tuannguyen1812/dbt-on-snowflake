select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    market_news_day_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.mart_market_news_sentiment_daily
where market_news_day_key is not null
group by market_news_day_key
having count(*) > 1



      
    ) dbt_internal_test