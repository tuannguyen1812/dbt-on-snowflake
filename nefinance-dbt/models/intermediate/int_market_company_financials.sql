{{ config(materialized = 'view') }}

with financials as (

    select * from {{ ref('stg_short_financials') }}

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
        case
            when liabilities = 0 then null
            else assets / liabilities
        end as asset_to_liability_ratio,
        case
            when liabilities_current = 0 then null
            else assets_current / liabilities_current
        end as current_ratio,
        case
            when assets = 0 then null
            else liabilities / assets
        end as liability_to_asset_ratio,
        case
            when assets = 0 then null
            else net_income_loss / assets
        end as return_on_assets,
        case
            when stockholders_equity = 0 then null
            else net_income_loss / stockholders_equity
        end as return_on_equity,
        case
            when common_stock_shares_issued = 0 then null
            else net_income_loss / common_stock_shares_issued
        end as earnings_per_share_basic,
        loaded_at
    from financials

)

select
    concat(ticker, '|', fiscal_year) as company_financial_year_key,
    *
from enriched
