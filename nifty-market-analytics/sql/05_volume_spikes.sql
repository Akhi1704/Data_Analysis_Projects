-- Find stocks with unusual trading volume (potential news/events)
SELECT 
    ticker,
    company,
    sector,
    date,
    ROUND(close::numeric, 2) as price,
    volume,
    ROUND(avg_volume_20d::numeric, 0) as avg_volume,
    ROUND(volume_ratio::numeric, 2) as volume_spike_ratio,
    ROUND(daily_return::numeric, 2) as return_on_spike_day
FROM stock_analytics
WHERE volume_spike = 1
    AND date >= (SELECT MAX(date) - INTERVAL '30 days' FROM stock_analytics)
ORDER BY volume_ratio DESC
LIMIT 30;