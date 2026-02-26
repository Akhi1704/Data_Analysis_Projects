-- Which sectors delivered the best risk-adjusted returns?
SELECT 
    sector,
    COUNT(DISTINCT ticker) as num_stocks,
    ROUND(AVG(return_1y)::numeric, 2) as avg_1y_return,
    ROUND(AVG(volatility_30d)::numeric, 2) as avg_volatility,
    ROUND(AVG(return_1y / NULLIF(volatility_30d, 0))::numeric, 2) as sharpe_ratio,
    ROUND(MAX(return_1y)::numeric, 2) as best_stock,
    ROUND(MIN(return_1y)::numeric, 2) as worst_stock
FROM stock_analytics
WHERE date = (SELECT MAX(date) FROM stock_analytics)
    AND return_1y IS NOT NULL
GROUP BY sector
ORDER BY avg_1y_return DESC;