Select * 
FROM {{ref('stg_sp500_prices')}}
WHERE close > 0 