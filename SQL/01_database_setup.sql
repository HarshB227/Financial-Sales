-- ============================================================================
-- Financial & Sales Analytics Dashboard - Database Setup
-- ============================================================================
-- Purpose: Create database and configure settings for retail analytics
-- Author: Portfolio Project
-- Date: 2024
-- ============================================================================

-- Drop database if exists (careful in production!)
DROP DATABASE IF EXISTS retail_analytics;

-- Create database with proper character set
CREATE DATABASE retail_analytics
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

-- Use the database
USE retail_analytics;

-- Display confirmation
SELECT 'Database retail_analytics created successfully!' AS Status;

-- Show database configuration
SELECT
    SCHEMA_NAME,
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'retail_analytics';
