CREATE DATABASE churn_analysis;
USE churn_analysis;
CREATE TABLE customer_churn (
    Customer_ID VARCHAR(50),
    Purchase_Freq INT,
    Avg_Order_Value FLOAT,
    Time_Between_Purchases INT,
    Lifetime_Value FLOAT,
    Region VARCHAR(50),
    Churn_Probability FLOAT
);
SHOW TABLES;
SELECT COUNT(*) FROM cleaned_customer_data;
DROP TABLE IF EXISTS customer_churn;
RENAME TABLE cleaned_customer_data TO customer_churn;
SELECT COUNT(*) FROM customer_churn;

#Top 5 customers in each region
SELECT *
FROM (
    SELECT 
        Product_ID,
        Region,
        Lifetime_Value,
        RANK() OVER (PARTITION BY Region ORDER BY Lifetime_Value DESC) AS rnk
    FROM customer_churn
) t
WHERE rnk <= 5;

#running total
SELECT 
    Product_ID,
    Lifetime_Value,
    SUM(Lifetime_Value) OVER (ORDER BY Product_ID) AS running_total
FROM customer_churn;

#Find customers above average value
SELECT *
FROM customer_churn
WHERE Lifetime_Value > (
    SELECT AVG(Lifetime_Value) FROM customer_churn
);

#Region with highest churn
SELECT Region, AVG(Churn_Probability) AS avg_churn
FROM customer_churn
GROUP BY Region
ORDER BY avg_churn DESC
LIMIT 1;

#Customers with highest purchase gap per region
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Region ORDER BY Time_Between_Purchases DESC) AS rn
    FROM customer_churn
) t
WHERE rn = 1;

#Categorize customers
SELECT 
    Product_ID,
    Lifetime_Value,
    CASE 
        WHEN Lifetime_Value > 5000 THEN 'High Value'
        WHEN Lifetime_Value BETWEEN 2000 AND 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_type
FROM customer_churn;

#Churn percentage
SELECT 
    ROUND(
        SUM(CASE WHEN Churn_Probability > 0.5 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS churn_percentage
FROM customer_churn;

#Top 3 regions by revenue
SELECT Region, SUM(Lifetime_Value) AS total_revenue
FROM customer_churn
GROUP BY Region
ORDER BY total_revenue DESC
LIMIT 3;