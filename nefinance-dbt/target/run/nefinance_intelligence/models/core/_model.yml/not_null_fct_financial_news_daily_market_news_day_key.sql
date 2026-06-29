select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select market_news_day_key
from NEFINANCE_DB.DEV.fct_financial_news_daily
where market_news_day_key is null



      
    ) dbt_internal_test