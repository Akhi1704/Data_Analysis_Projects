/*
===============================================================================
PROJECT: Public Grievance Redressal System (PGRS) Analytics
DESCRIPTION: 
    End-to-end data engineering pipeline. 
    1. Database Setup & Schema Creation
    2. ETL: Loading raw CSV data (handling Unicode/Telugu text)
    3. Data Cleaning: Date standardization & duplicate removal
    4. Transformation: Creating strategic categories & location extraction
    5. Final View: Export-ready dataset for Power BI
===============================================================================
*/

-- Environment Setup
-- Enabling local file loading for bulk import
SET GLOBAL local_infile = 1;

CREATE DATABASE IF NOT EXISTS pgrs_analytics;
USE pgrs_analytics;

-- ============================================================================
-- STEP 1: SCHEMA DEFINITION (DDL)
-- ============================================================================
-- Dropping existing table to ensure a fresh start. 
-- Using utf8mb4 to preserve Telugu characters in 'Remarks'.
DROP TABLE IF EXISTS grievances;

CREATE TABLE grievances (
    grievance_id TEXT,
    citizen_name TEXT,
    registration_date_str TEXT,  -- Loading as text first to handle format inconsistencies
    address TEXT,
    officer_details TEXT,
    source_mode TEXT,
    department TEXT,
    subject TEXT,
    sub_subject TEXT,
    remarks TEXT,
    status TEXT,
    registration_date DATE       -- Added for the cleaned date value
) CHARACTER SET utf8mb4;

-- ============================================================================
-- STEP 2: ETL - DATA INGESTION
-- ============================================================================
-- Loading ~2,500 records from the raw CSV.
-- Note: 'IGNORE 1 ROWS' skips the header.

LOAD DATA LOCAL INFILE 'C:/Users/Akhilesh/Downloads/pgrs_master_data.csv'
INTO TABLE grievances
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n' 
IGNORE 1 ROWS
(grievance_id, citizen_name, registration_date_str, address, officer_details, source_mode, department, subject, sub_subject, remarks, status);

-- ============================================================================
-- STEP 3: DATA CLEANING & STANDARDIZATION
-- ============================================================================

-- Disable Safe Updates to allow bulk cleaning
SET SQL_SAFE_UPDATES = 0;

-- 3.1: Remove "Ghost Rows" (Headers that got imported as data)
DELETE FROM grievances 
WHERE department = 'DEPARTMENT' OR grievance_id = 'Grievance No';

-- 3.2: Date Standardization
-- Converting text dates (DD-MM-YYYY) into SQL Date format for Time Series Analysis.
UPDATE grievances 
SET registration_date = STR_TO_DATE(TRIM(registration_date_str), '%d-%m-%Y')
WHERE registration_date_str LIKE '%-%';

-- ============================================================================
-- STEP 4: ANALYTICAL QUERIES (Exploratory Data Analysis)
-- ============================================================================

-- Identifying which departments contribute to the majority of volume.
SELECT 
    department, 
    COUNT(*) AS total_grievances,
    ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM grievances)), 2) AS pct_share,
    -- Window Function for Cumulative Percentage
    ROUND(SUM(COUNT(*)) OVER (ORDER BY COUNT(*) DESC) * 100.0 / (SELECT COUNT(*) FROM grievances), 2) AS cumulative_pct
FROM 
    grievances
GROUP BY 
    department
ORDER BY 
    total_grievances DESC;

-- Validating that our keyword search accurately tags issues before finalizing the View.
SELECT 
    department,
    subject,
    CASE 
        WHEN department IN ('Revenue (CCLA)', 'Survey Settlements and Land Records') THEN 'Land & Revenue'
        WHEN department LIKE '%Police%' THEN 'Law & Order'
        WHEN subject LIKE '%Drain%' OR subject LIKE '%Road%' THEN 'Infrastructure'
        ELSE 'Other'
    END AS test_category
FROM 
    grievances
LIMIT 20;

-- ============================================================================
-- STEP 5: FINAL VIEW CREATION (For Power BI)
-- ============================================================================
-- Creating a virtual table that summarizes all transformation logic.

CREATE OR REPLACE VIEW v_pgrs_dashboard_data AS
SELECT 
    grievance_id,
    registration_date,
    
    -- Transformation 1: Location Extraction
    -- Parsing the Mandal/City name from the unstructured Address string.
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',', 2), ',', -1)) AS mandal_name,
    
    department,
    subject,
    status,
    
    -- Transformation 2: Strategic Categorization Framework
    -- Grouping 30+ Departments into 6 Core Strategic Pillars for executive reporting.
    CASE 
        -- Tier 1: Department-Based Rules 
        WHEN department IN ('Revenue (CCLA)', 'Survey Settlements and Land Records', 'Registration and Stamps') THEN 'Land & Revenue'
        WHEN department IN ('Police', 'Prohibition and Excise', 'Home') THEN 'Law & Order'
        WHEN department IN ('Municipal Administration', 'Panchayati Raj', 'Rural Water Supply Engineering', 'Roads and Buildings (E-in-C)', 'Water Resources') THEN 'Infrastructure & Civic Works'
        WHEN department IN ('School Education', 'Higher Education', 'Medical Education', 'Family Welfare', 'Dr. NTR Vaidya Seva Trust') THEN 'Education & Health'
        WHEN department IN ('Social Welfare', 'BC Welfare', 'Women Development and Child Welfare', 'Civil Supplies') THEN 'Welfare Schemes'
        WHEN department IN ('Agriculture', 'Animal Husbandry', 'Horticulture') THEN 'Agriculture & Allied'
        
        -- Tier 2: Subject-Based Rules (For generic departments)
        WHEN subject LIKE '%Pension%' OR subject LIKE '%Ration%' THEN 'Welfare Schemes'
        WHEN subject LIKE '%Drain%' OR subject LIKE '%Road%' OR subject LIKE '%Water%' THEN 'Infrastructure & Civic Works'
        
        -- Default Fallback
        ELSE 'General Administration'
    END AS category_group
FROM 
    grievances
WHERE 
    grievance_id IS NOT NULL;

-- Viewing our final dataset for visualization
SELECT * FROM v_pgrs_dashboard_data LIMIT 100;

