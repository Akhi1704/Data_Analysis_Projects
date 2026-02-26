-- Identify overbought and oversold stocks using RSI
SELECT 
    ticker,
    company,
    sector,
    ROUND(close::numeric, 2) as price,
    ROUND(rsi::numeric, 1) as rsi,
    ROUND(return_1y::numeric, 2) as return_1y,
    CASE 
        WHEN rsi > 70 THEN 'Overbought - Consider Selling'
        WHEN rsi > 60 THEN 'Strong - Monitor'
        WHEN rsi < 30 THEN 'Oversold - Potential Buy'
        WHEN rsi < 40 THEN 'Weak - Monitor'
        ELSE 'Neutral'
    END as trading_signal
FROM stock_analytics
WHERE date = (SELECT MAX(date) FROM stock_analytics)
    AND rsi IS NOT NULL
ORDER BY rsi;