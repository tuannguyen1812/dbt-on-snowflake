
    
    

select
    company_financial_year_key as unique_field,
    count(*) as n_records

from NEFINANCE_DB.DEV.fct_company_financials_yearly
where company_financial_year_key is not null
group by company_financial_year_key
having count(*) > 1


