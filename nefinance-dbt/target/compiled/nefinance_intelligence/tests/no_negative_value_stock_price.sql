Select * 
FROM NEFINANCE_DB.DEV.stg_sp500_prices
WHERE open_price < 0 or high_price < 0 or low_price < 0 or close_price < 0 or adjusted_close_price < 0 or volume < 0