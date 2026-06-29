select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        dominant_sentiment as value_field,
        count(*) as n_records

    from NEFINANCE_DB.DEV.fct_financial_news_daily
    group by dominant_sentiment

)

select *
from all_values
where value_field not in (
    'Positive','Neutral','Negative'
)



      
    ) dbt_internal_test