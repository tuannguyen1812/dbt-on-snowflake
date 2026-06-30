
  create or replace   view NEFINANCE_DB.DEV.int_market_company_financials
  
   as (
    

with financials as (

    select * from NEFINANCE_DB.DEV.stg_short_financials

),

enriched as (

    select
        ticker,
        cik,
        fiscal_year,
        price,
        price_date,
        report_date,
        assets,
        assets_current,
        cash_and_cash_equivalents,
        common_stock_shares_issued,
        common_stock_value,
        income_tax_expense_benefit,
        liabilities_current,
        operating_income_loss,
        stockholders_equity,
        net_income_loss,
        liabilities,
        (assets / nullif(liabilities, 0)) as asset_to_liability_ratio,
        (assets_current / nullif(liabilities_current, 0)) as current_ratio,
        (liabilities / nullif(assets, 0)) as liability_to_asset_ratio,
        (net_income_loss / nullif(assets, 0)) as return_on_assets,
        (net_income_loss / nullif(stockholders_equity, 0)) as return_on_equity,
        (net_income_loss / nullif(common_stock_shares_issued, 0)) as earnings_per_share_basic,
        loaded_at
    from financials

),

deduplicated as (

    select *
    from enriched
    qualify row_number() over (
        partition by ticker, fiscal_year
        order by report_date desc, price_date desc, loaded_at desc
    ) = 1

)

select
    concat(ticker, '|', fiscal_year) as company_financial_year_key,
    *
from deduplicated
  );

