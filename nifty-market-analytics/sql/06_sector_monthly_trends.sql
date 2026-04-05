-- Monthly sector performance to identify trends
SELECT 
    DATE_TRUNC('month', date) as month,
    sector,
    ROUND(AVG(daily_return)::numeric, 3) as avg_daily_return,
    COUNT(DISTINCT ticker) as stocks_tracked,
    ROUND(AVG(volume)::numeric, 0) as avg_volume
FROM stock_analytics
WHERE date >= (SELECT MAX(date) - INTERVAL '12 months' FROM stock_analytics)
GROUP BY DATE_TRUNC('month', date), sector
ORDER BY month DESC, avg_daily_return DESC;