select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select news_article_key
from NEFINANCE_DB.DEV.int_market_news_sentiment
where news_article_key is null



      
    ) dbt_internal_test