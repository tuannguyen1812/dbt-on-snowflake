

with source as (

    select *
    from PC_FIVETRAN_DB.GOOGLE_DRIVE.SHORT_FINANCIALS

),

renamed as (

    select

        ticker,
        cik,
        fiscal_year,

        price,
        price_date,

        ddate as report_date,

        assets,
        assets_current,

        cash_and_cash_equivalents_at_carrying_value
            as cash_and_cash_equivalents,

        common_stock_shares_issued,
        common_stock_value,

        income_tax_expense_benefit,

        liabilities_current,

        operating_income_loss,

        stockholders_equity,

        net_income_loss,

        liabilities,

        _fivetran_synced as loaded_at

    from source

),

deduplicated as (

    select *

    from renamed

    qualify row_number() over (

        partition by
            ticker,
            fiscal_year,
            report_date

        order by loaded_at desc

    ) = 1

)

select *
from deduplicated