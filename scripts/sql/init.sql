-- =============================================================================
-- MASTER DATABASE INITIALIZATION SCRIPT
-- Description: Runs all database initialization scripts in order
-- Usage: mysql -u root -p < scripts/sql/init.sql
-- =============================================================================

-- Load environment variables (if using bash)
-- source ../.env

-- =============================================================================
-- STEP 1: Create User Database (Identity Service)
-- =============================================================================
\. 01_user_db.sql

-- =============================================================================
-- STEP 2: Create Product Database (Product Service)
-- =============================================================================
\. 02_product_db.sql

-- =============================================================================
-- STEP 3: Create Order and Payment Databases
-- =============================================================================
\. 03_order_db.sql

-- =============================================================================
-- FINAL: Verify all databases
-- =============================================================================
SHOW DATABASES;
SELECT 'All databases initialized successfully!' AS message;