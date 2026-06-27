select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      Select * 
FROM NEFINANCE_DB.DEV.stg_sp500_prices
WHERE close > 0
      
    ) dbt_internal_test