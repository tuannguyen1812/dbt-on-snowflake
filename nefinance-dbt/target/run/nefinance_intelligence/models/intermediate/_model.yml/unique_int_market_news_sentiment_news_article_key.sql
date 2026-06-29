select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    news_article_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.int_market_news_sentiment
where news_article_key is not null
group by news_article_key
having count(*) > 1



      
    ) dbt_internal_test