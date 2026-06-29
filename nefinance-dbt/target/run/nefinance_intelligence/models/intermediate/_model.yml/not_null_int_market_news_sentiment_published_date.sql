select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select published_date
from NEFINANCE_DB.DEV.int_market_news_sentiment
where published_date is null



      
    ) dbt_internal_test