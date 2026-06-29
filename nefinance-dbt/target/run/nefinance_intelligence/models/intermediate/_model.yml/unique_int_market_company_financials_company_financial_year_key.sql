select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    company_financial_year_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.int_market_company_financials
where company_financial_year_key is not null
group by company_financial_year_key
having count(*) > 1



      
    ) dbt_internal_test