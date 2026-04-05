-- Classify all stocks by performance and risk profile
WITH latest_metrics AS (
    SELECT 
        ticker,
        company,
        sector,
        close,
        return_1y,
        return_3m,
        volatility_30d,
        rsi,
        pct_from_high_52w,
        RANK() OVER (ORDER BY return_1y DESC) as return_rank
    FROM stock_analytics
    WHERE date = (SELECT MAX(date) FROM stock_analytics)
        AND return_1y IS NOT NULL
)
SELECT 
    ticker,
    company,
    sector,
    ROUND(return_1y::numeric, 2) as return_1y_pct,
    ROUND(volatility_30d::numeric, 2) as volatility,
    ROUND(rsi::numeric, 1) as rsi,
    return_rank,
    CASE 
        WHEN return_1y > 20 AND volatility_30d < 2 THEN 'High Return - Low Risk ⭐'
        WHEN return_1y > 20 AND volatility_30d >= 2 THEN 'High Return - High Risk'
        WHEN return_1y > 0 AND volatility_30d < 2 THEN 'Stable Performer'
        WHEN return_1y < 0 AND volatility_30d >= 2 THEN 'High Risk - Negative Return ⚠️'
        ELSE 'Underperformer'
    END as investment_profile
FROM latest_metrics
ORDER BY return_1y DESC;