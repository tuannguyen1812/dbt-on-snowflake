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
        {{ safe_divide('assets', 'liabilities') }} as asset_to_liability_ratio,
        {{ safe_divide('assets_current', 'liabilities_current') }} as current_ratio,
        {{ safe_divide('liabilities', 'assets') }} as liability_to_asset_ratio,
        {{ safe_divide('net_income_loss', 'assets') }} as return_on_assets,
        {{ safe_divide('net_income_loss', 'stockholders_equity') }} as return_on_equity,
        {{ safe_divide('net_income_loss', 'common_stock_shares_issued') }} as earnings_per_share_basic,
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
