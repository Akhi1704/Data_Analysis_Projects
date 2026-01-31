-- ============================================================
-- STREE SHAKTI DATABASE CREATION
-- ============================================================

-- Drop database if exists (for fresh start)
DROP DATABASE IF EXISTS stree_shakti_analytics;

-- Create database
CREATE DATABASE stree_shakti_analytics;
USE stree_shakti_analytics;

-- ============================================================
-- MAIN TRIPS TABLE
-- ============================================================

CREATE TABLE trips (
    trip_id VARCHAR(20) PRIMARY KEY COMMENT 'Unique trip identifier',
    date DATE NOT NULL COMMENT 'Trip date',
    time TIME NOT NULL COMMENT 'Trip time',
    hour INT NOT NULL CHECK (hour >= 0 AND hour <= 23) COMMENT 'Hour of day (0-23)',
    day_of_week VARCHAR(10) NOT NULL COMMENT 'Day name',
    bus_id VARCHAR(20) NOT NULL COMMENT 'Bus identifier',
    route_category VARCHAR(20) NOT NULL CHECK (route_category IN ('urban', 'peri-urban', 'rural')) COMMENT 'Route type',
    distance_km DECIMAL(5,1) NOT NULL COMMENT 'Trip distance in km',
    passenger_gender CHAR(1) NOT NULL CHECK (passenger_gender IN ('M', 'F')) COMMENT 'Passenger gender',
    passenger_type VARCHAR(30) NOT NULL COMMENT 'Passenger category',
    age_group VARCHAR(20) NOT NULL COMMENT 'Age group',
    normal_fare INT NOT NULL COMMENT 'Regular fare in rupees',
    revenue_loss INT NOT NULL COMMENT 'Government revenue foregone',
    occupancy_pct INT NOT NULL CHECK (occupancy_pct >= 0 AND occupancy_pct <= 100) COMMENT 'Bus occupancy %',
    month INT COMMENT 'Month (1-12)',
    week INT COMMENT 'Week number',
    day INT COMMENT 'Day of month',
    is_weekend TINYINT COMMENT 'Weekend indicator',
    time_period VARCHAR(20) COMMENT 'Time period classification',
    occupancy_category VARCHAR(20) COMMENT 'Occupancy classification',
    beneficiary_trip TINYINT COMMENT 'Stree Shakti beneficiary indicator',
    concessional_trip TINYINT COMMENT 'Concessional passenger indicator',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Record creation timestamp'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Main trips data table';

-- ============================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================

CREATE INDEX idx_date ON trips(date) COMMENT 'Index for date-based queries';
CREATE INDEX idx_hour ON trips(hour) COMMENT 'Index for hourly analysis';
CREATE INDEX idx_passenger_type ON trips(passenger_type) COMMENT 'Index for passenger type analysis';
CREATE INDEX idx_route_category ON trips(route_category) COMMENT 'Index for route analysis';
CREATE INDEX idx_bus_id ON trips(bus_id) COMMENT 'Index for bus-level analysis';
CREATE INDEX idx_date_hour ON trips(date, hour) COMMENT 'Composite index for time-based queries';

-- ============================================================
-- AGGREGATE TABLES FOR PERFORMANCE
-- ============================================================

CREATE TABLE daily_summary (
    summary_date DATE PRIMARY KEY,
    total_trips INT,
    daily_revenue_loss BIGINT,
    avg_occupancy DECIMAL(5,2),
    buses_operated INT,
    female_trips INT,
    stree_shakti_trips INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Daily aggregated metrics';

CREATE INDEX idx_daily_date ON daily_summary(summary_date);

CREATE TABLE hourly_summary (
    summary_date DATE,
    hour INT,
    trip_count INT,
    revenue_loss BIGINT,
    avg_occupancy DECIMAL(5,2),
    avg_distance DECIMAL(5,1),
    female_percentage DECIMAL(5,2),
    PRIMARY KEY (summary_date, hour)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Hourly aggregated metrics';

CREATE TABLE route_summary (
    route_category VARCHAR(20) PRIMARY KEY,
    total_trips INT,
    avg_distance DECIMAL(5,1),
    avg_occupancy DECIMAL(5,2),
    total_revenue_loss BIGINT,
    unique_buses INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Route-level summary metrics';

-- Verify tables created
SHOW TABLES;
SELECT 'Database created successfully!' as status;
