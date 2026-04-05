-- ============================================================
-- STREE SHAKTI PROJECT - ANALYSIS QUERIES
-- ============================================================

USE stree_shakti_analytics;

-- ============================================================
-- QUERY 1: OPERATIONAL EFFICIENCY - PEAK HOURS
-- ============================================================

SELECT 
    hour,
    COUNT(*) as trip_count,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
    MAX(occupancy_pct) as peak_occupancy,
    ROUND(AVG(distance_km), 1) as avg_distance,
    ROUND(100.0 * SUM(CASE WHEN passenger_type = 'Stree_Shakti' THEN 1 ELSE 0 END) / COUNT(*), 1) as stree_shakti_pct,
    COUNT(DISTINCT bus_id) as buses_used
FROM trips
WHERE hour IN (8, 9, 17, 18)
GROUP BY hour
ORDER BY hour;

-- ============================================================
-- QUERY 2: ROUTE PERFORMANCE ANALYSIS
-- ============================================================

SELECT 
    route_category,
    COUNT(*) as trips,
    ROUND(AVG(distance_km), 1) as avg_distance,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
    SUM(revenue_loss) as total_revenue_loss,
    COUNT(DISTINCT bus_id) as unique_buses,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM trips), 1) as trip_percentage
FROM trips
GROUP BY route_category
ORDER BY total_revenue_loss DESC;

-- ============================================================
-- QUERY 3: BENEFICIARY IMPACT - MONTHLY TREND
-- ============================================================

SELECT 
    DATE_FORMAT(date, '%Y-%m') as month,
    COUNT(*) as total_beneficiary_trips,
    COUNT(DISTINCT bus_id) as buses_used,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
    SUM(revenue_loss) as total_monthly_savings,
    ROUND(AVG(distance_km), 1) as avg_distance,
    ROUND(SUM(revenue_loss) / COUNT(DISTINCT bus_id), 0) as savings_per_bus,
    ROUND(SUM(revenue_loss) / COUNT(*), 0) as avg_savings_per_trip
FROM trips
WHERE passenger_type = 'Stree_Shakti'
GROUP BY DATE_FORMAT(date, '%Y-%m')
ORDER BY month;

-- ============================================================
-- QUERY 4: REVENUE LOSS BY PASSENGER TYPE
-- ============================================================

SELECT 
    passenger_type,
    COUNT(*) as total_trips,
    SUM(revenue_loss) as total_revenue_loss,
    ROUND(AVG(revenue_loss), 0) as avg_loss_per_trip,
    ROUND(100.0 * SUM(revenue_loss) / (SELECT SUM(revenue_loss) FROM trips), 1) as loss_percentage,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM trips), 1) as trip_percentage
FROM trips
GROUP BY passenger_type
ORDER BY total_revenue_loss DESC;

-- ============================================================
-- QUERY 5: OVERALL FINANCIAL IMPACT SUMMARY
-- ============================================================

SELECT 
    SUM(revenue_loss) as total_annual_revenue_loss,
    COUNT(*) as total_trips,
    COUNT(DISTINCT bus_id) as unique_buses,
    COUNT(DISTINCT DATE(date)) as days_operated,
    ROUND(SUM(revenue_loss) / COUNT(DISTINCT bus_id), 0) as avg_loss_per_bus,
    ROUND(SUM(revenue_loss) / COUNT(DISTINCT DATE(date)), 0) as avg_loss_per_day,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy_overall,
    ROUND(AVG(distance_km), 1) as avg_distance_overall,
    (SELECT COUNT(*) FROM trips WHERE passenger_type = 'Stree_Shakti') as stree_shakti_trips,
    (SELECT COUNT(*) FROM trips WHERE passenger_gender = 'F') as female_trips
FROM trips;

-- ============================================================
-- QUERY 6: OCCUPANCY DISTRIBUTION ANALYSIS
-- ============================================================

SELECT 
    CASE 
        WHEN occupancy_pct > 90 THEN 'Overcrowded (>90%)'
        WHEN occupancy_pct > 75 THEN 'High (75-90%)'
        WHEN occupancy_pct > 50 THEN 'Medium (50-75%)'
        ELSE 'Low (<50%)'
    END as occupancy_class,
    COUNT(*) as trip_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM trips), 1) as percentage_of_trips,
    ROUND(AVG(revenue_loss), 0) as avg_revenue_loss,
    ROUND(AVG(distance_km), 1) as avg_distance
FROM trips
GROUP BY occupancy_class
ORDER BY trip_count DESC;

-- ============================================================
-- QUERY 7: HOURLY REVENUE LOSS TREND
-- ============================================================

SELECT 
    DATE(date) as date,
    COUNT(*) as daily_trips,
    SUM(revenue_loss) as daily_loss,
    ROUND(SUM(revenue_loss) / COUNT(*), 0) as avg_loss_per_trip,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
    COUNT(DISTINCT bus_id) as buses_operated
FROM trips
GROUP BY DATE(date)
ORDER BY date DESC
LIMIT 30;

-- ============================================================
-- QUERY 8: TOP 20 BUSES BY EFFICIENCY
-- ============================================================

SELECT 
    bus_id,
    COUNT(*) as total_trips,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
    ROUND(AVG(distance_km), 1) as avg_distance,
    SUM(revenue_loss) as total_revenue_loss,
    COUNT(DISTINCT DATE(date)) as days_operated
FROM trips
GROUP BY bus_id
ORDER BY total_trips DESC
LIMIT 20;

-- ============================================================
-- QUERY 9: TIME PERIOD ANALYSIS
-- ============================================================

SELECT 
    time_period,
    COUNT(*) as trip_count,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
    SUM(revenue_loss) as total_revenue_loss,
    COUNT(DISTINCT bus_id) as buses_used,
    ROUND(100.0 * SUM(CASE WHEN passenger_type = 'Stree_Shakti' THEN 1 ELSE 0 END) / COUNT(*), 1) as stree_shakti_percentage
FROM trips
GROUP BY time_period
ORDER BY avg_occupancy DESC;

-- ============================================================
-- QUERY 10: WEEKLY TREND ANALYSIS
-- ============================================================

SELECT 
    day_of_week,
    COUNT(*) as trip_count,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy,
    SUM(revenue_loss) as total_revenue_loss,
    ROUND(AVG(revenue_loss), 0) as avg_loss_per_trip,
    COUNT(DISTINCT bus_id) as buses_used
FROM trips
GROUP BY day_of_week
ORDER BY 
    CASE day_of_week
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- ============================================================
-- QUERY 11: AGE GROUP ANALYSIS
-- ============================================================

SELECT 
    age_group,
    COUNT(*) as trip_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM trips), 1) as trip_percentage,
    SUM(revenue_loss) as total_revenue_loss,
    ROUND(100.0 * SUM(revenue_loss) / (SELECT SUM(revenue_loss) FROM trips), 1) as revenue_loss_percentage,
    ROUND(AVG(occupancy_pct), 1) as avg_occupancy
FROM trips
GROUP BY age_group
ORDER BY trip_count DESC;

-- ============================================================
-- QUERY 12: ROI FOUNDATION NUMBERS
-- ============================================================

SELECT 
    'Financial Summary' as metric,
    CONCAT('₹', FORMAT(SUM(revenue_loss) / 10000000, 2), ' Crore') as value
FROM trips

UNION ALL

SELECT 
    'Total Trips' as metric,
    CONCAT(FORMAT(COUNT(*), 0), ' trips') as value
FROM trips

UNION ALL

SELECT 
    'Beneficiaries Served' as metric,
    CONCAT(FORMAT(COUNT(DISTINCT trip_id), 0), ' unique trips') as value
FROM trips
WHERE passenger_type = 'Stree_Shakti'

UNION ALL

SELECT 
    'Average Daily Savings' as metric,
    CONCAT('₹', FORMAT(
        (SELECT SUM(revenue_loss) FROM trips) / COUNT(DISTINCT DATE(date)), 
        0
    )) as value
FROM trips;


