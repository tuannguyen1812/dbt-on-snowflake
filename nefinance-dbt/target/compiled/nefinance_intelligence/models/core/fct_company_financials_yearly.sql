

with financials as (

    select * from NEFINANCE_DB.DEV.int_market_company_financials
    
        where loaded_at >= (
            select coalesce(
                max(latest_loaded_at),
                to_timestamp_tz('1900-01-01 00:00:00 +00:00')
            )
            from NEFINANCE_DB.DEV.fct_company_financials_yearly
        )
    

),

companies as (

    select company_key, ticker
    from NEFINANCE_DB.DEV.dim_market_company

)

select
    financials.company_financial_year_key,
    companies.company_key,
    to_number(to_varchar(financials.report_date, 'YYYYMMDD')) as report_date_key,
    financials.ticker,
    financials.cik,
    financials.fiscal_year,
    financials.price,
    financials.price_date,
    financials.report_date,
    financials.assets,
    financials.assets_current,
    financials.cash_and_cash_equivalents,
    financials.common_stock_shares_issued,
    financials.common_stock_value,
    financials.income_tax_expense_benefit,
    financials.liabilities_current,
    financials.operating_income_loss,
    financials.stockholders_equity,
    financials.net_income_loss,
    financials.liabilities,
    financials.asset_to_liability_ratio,
    financials.current_ratio,
    financials.liability_to_asset_ratio,
    financials.return_on_assets,
    financials.return_on_equity,
    financials.earnings_per_share_basic,
    financials.loaded_at as latest_loaded_at,
    current_timestamp as transformed_at
from financials
left join companies
    on financials.ticker = companies.ticker