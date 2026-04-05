-- Find low-volatility stocks with consistent positive returns
SELECT 
    ticker,
    company,
    sector,
    ROUND(return_1y::numeric, 2) as return_1y,
    ROUND(return_3m::numeric, 2) as return_3m,
    ROUND(volatility_30d::numeric, 2) as volatility,
    ROUND(close::numeric, 2) as current_price,
    CASE 
        WHEN volatility_30d < 1.0 THEN 'Very Stable'
        WHEN volatility_30d < 1.5 THEN 'Stable'
        WHEN volatility_30d < 2.0 THEN 'Moderate'
        ELSE 'High Volatility'
    END as volatility_category
FROM stock_analytics
WHERE date = (SELECT MAX(date) FROM stock_analytics)
    AND return_1y IS NOT NULL
ORDER BY volatility_30d ASC
LIMIT 20;