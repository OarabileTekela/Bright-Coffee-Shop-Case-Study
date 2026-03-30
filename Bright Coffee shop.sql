select * from `workspace`.`default`.`bright_coffee_shop_analysis_case_study_1_2` limit 100;
-- ============================================
-- Bright Coffee Shop Sales Analysis
SELECT *,
    CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS unit_price_clean
FROM bright_coffee_shop_analysis_case_study_1_2;

SELECT *,
    CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) * transaction_qty AS total_amount
FROM bright_coffee_shop_analysis_case_study_1_2;


-- ============================================
-- STEP 3: CREATE transaction_time_bucket
-- Group into 30-minute intervals
-- ============================================

SELECT *,
    CONCAT(
        HOUR(TO_TIMESTAMP(transaction_time)), ':',
        CASE 
            WHEN MINUTE(TO_TIMESTAMP(transaction_time)) < 30 THEN '00'
            ELSE '30'
        END
    ) AS transaction_time_bucket
FROM bright_coffee_shop_analysis_case_study_1_2;


-- ============================================
-- STEP 4: CREATE CLEAN TABLE (BEST PRACTICE)
-- ============================================

CREATE OR REPLACE TABLE coffee_sales_clean AS
SELECT
    transaction_id,
    transaction_date,
    transaction_time,
    transaction_qty,
    store_id,
    store_location,
    product_id,

    -- Clean unit price
    CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) AS unit_price,

    product_category,
    product_type,
    product_detail,

    -- Total revenue per transaction
    CAST(REPLACE(unit_price, ',', '.') AS DOUBLE) * transaction_qty AS total_amount,

    -- Time bucket (30-min intervals)
    CONCAT(
        HOUR(TO_TIMESTAMP(transaction_time)), ':',
        CASE 
            WHEN MINUTE(TO_TIMESTAMP(transaction_time)) < 30 THEN '00'
            ELSE '30'
        END
    ) AS transaction_time_bucket

FROM bright_coffee_shop_analysis_case_study_1_2;


-- ============================================
-- ANALYSIS QUERIES (FOR INSIGHTS)
-- ============================================

-- 1. Total Revenue
SELECT 
    SUM(total_amount) AS total_revenue
FROM coffee_sales_clean;


-- 2. Total Units Sold
SELECT 
    SUM(transaction_qty) AS total_units_sold
FROM coffee_sales_clean;


-- 3. Revenue by Product Type
SELECT 
    product_type,
    SUM(total_amount) AS revenue
FROM coffee_sales_clean
GROUP BY product_type;


-- 4. Revenue by Product Category
SELECT 
    product_category,
    SUM(total_amount) AS revenue
FROM coffee_sales_clean
GROUP BY product_category;


-- 5. Top-Selling Products (by quantity)
SELECT 
    product_detail,
    SUM(transaction_qty) AS total_sold
FROM coffee_sales_clean
GROUP BY product_detail
ORDER BY total_sold DESC;


-- 6. Low-Performing Products
SELECT 
    product_detail,
    SUM(transaction_qty) AS total_sold
FROM coffee_sales_clean
GROUP BY product_detail
ORDER BY total_sold ASC;


-- 7. Revenue by Time Interval
SELECT 
    transaction_time_bucket,
    SUM(total_amount) AS revenue
FROM coffee_sales_clean
GROUP BY transaction_time_bucket;


-- 8. Peak Sales Period
SELECT 
    transaction_time_bucket,
    SUM(total_amount) AS revenue
FROM coffee_sales_clean
GROUP BY transaction_time_bucket
ORDER BY revenue DESC
LIMIT 1;


-- 9. Low Sales Period
SELECT 
    transaction_time_bucket,
    SUM(total_amount) AS revenue
FROM coffee_sales_clean
GROUP BY transaction_time_bucket
ORDER BY revenue ASC
LIMIT 1;


-- 10. Average Transaction Value
SELECT 
    SUM(total_amount) / COUNT(transaction_id) AS avg_transaction_value
FROM coffee_sales_clean;
