
    
    

select
    news_article_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.int_market_news_sentiment
where news_article_key is not null
group by news_article_key
having count(*) > 1


