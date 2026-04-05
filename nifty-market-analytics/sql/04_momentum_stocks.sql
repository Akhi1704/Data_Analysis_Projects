-- Identify momentum stocks (near 52-week high = strong trend)
SELECT 
    ticker,
    company,
    sector,
    ROUND(close::numeric, 2) as current_price,
    ROUND(high_52w::numeric, 2) as high_52w,
    ROUND(pct_from_high_52w::numeric, 2) as pct_from_high,
    ROUND(return_3m::numeric, 2) as return_3m,
    ROUND(return_1y::numeric, 2) as return_1y,
    ROUND(rsi::numeric, 1) as rsi,
    CASE 
        WHEN pct_from_high_52w >= -2 THEN 'At 52W High - Strong Momentum'
        WHEN pct_from_high_52w >= -5 THEN 'Near 52W High - Bullish'
        WHEN pct_from_high_52w >= -10 THEN 'Moderate Pullback'
        ELSE 'Deep Correction'
    END as momentum_signal
FROM stock_analytics
WHERE date = (SELECT MAX(date) FROM stock_analytics)
    AND return_1y IS NOT NULL
ORDER BY pct_from_high_52w DESC;