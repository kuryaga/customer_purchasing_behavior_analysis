select *
from customers
LIMIT(10);

-- 1. How many customers does the store have?
-- + Checking for duplicates, missing values, and unusual values.

SELECT COUNT(*) as total_clients,
    COUNT(DISTINCT(user_id)) AS unique_customers
from customers;

-- There are 238 customers with 238 unique customer IDs.
-- No duplicate customer IDs were found.

SELECT
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS missing_id,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN annual_income IS NULL THEN 1 ELSE 0 END) AS missing_income,
    SUM(CASE WHEN purchase_amount IS NULL THEN 1 ELSE 0 END) AS missing_purchase,
    SUM(CASE WHEN loyalty_score IS NULL THEN 1 ELSE 0 END) AS missing_loyalty,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN purchase_frequency IS NULL THEN 1 ELSE 0 END) AS missing_frequency
FROM customers;

-- No missing values were found in the dataset.

SELECT *
FROM customers
WHERE age < 0
   OR annual_income < 0
   OR purchase_amount < 0
   OR purchase_frequency < 0
   OR loyalty_score < 0;

-- No negative values were found in the numerical columns.

-- 2. What is the average income for the clients who come to this store? 

SELECT 
    ROUND(AVG(annual_income), 2) as annual_income, 
    ROUND(AVG(annual_income)/12, 2) as monthly_income,
    MIN(annual_income) as min_annual_income,
    MAX(annual_income) as max_annual_income
FROM customers;

-- The average annual income of the customers, rounded to 2 decimal points, is $57407.56.
-- The average monthly income is $4783.96.
-- The lowest annual income is $30000, while the highest annual income is $75000.

-- 3. What is the client average annual income by age?
-- What is the average purchase amount by age?

select 
    avg(age) as avg_age, 
    min(age) as min_age,
    max(age) as max_age
from customers;

-- The min age - 22, max age - 55, and average age - 38.

SELECT
    CASE
        when age <= 30 then '30 & younger'
        when age <= 40 then '31-40 years old'
        else 'older than 40'
    end as age_group,
    round(avg(annual_income), 2) as avg_annual_income,
    round(avg(purchase_amount), 2) as avg_purchase_amount,
    count(user_id) as client_count
FROM customers
Group by 1;

-- The age with the highest average purchase amount, based on age, is group "older than 40".
-- Clients who are older than 40 are also the majority who visit the website. 
-- Clients who are in the group "40 and older" make up the highest purchase amount. 

-- 4. What is the average income and purchase amount by loyalty score?

SELECT
    CASE
        when loyalty_score <= 5 then 'score of 5 and lower'
        else 'score higher than 5'
    end as loyalty_score,
    round(avg(annual_income), 2) as avg_annual_income,
    round(avg(purchase_amount), 2) as avg_purchase_amount,
    count(user_id) as client_count
FROM customers
Group by 1;

-- There are more customers with a loyalty score higher than 5.0.
-- Customers whose loyalty score is higher than 5 have a higher average annual income and a higher purchase amount compared to customers with a lower loyalty score. 

-- 5. What is the average income and purchase amount by purchase frequency?
-- a. all
select 
    avg(purchase_frequency) as avg_freq, 
    min(purchase_frequency) as min_freq,
    max(purchase_frequency) as max_freq
from customers;

-- The minimum purchase frequency is 10. 
-- The maximum purchase frequency is 28. 
-- The average purchase frequency is approximately 20. 

SELECT
    CASE
        when purchase_frequency <= 16 then '<= 16'
        when purchase_frequency <= 23 then '<= 23'
        else '> 23'
    end as purchase_frequency_group,
     round(avg(annual_income), 2) as avg_annual_income,
    round(avg(purchase_amount), 2) as avg_purchase_amount,   
    count(user_id) as client_count
FROM customers
GROUP BY 1;

-- The higher the purchase frequency the higher the average income and purchase amount.
-- The group that has the highest number of clients are those with a purchase frequency between 17 and 23, not the highest frequency group. 
-- Conclusion: The marketing should target both the clients with the highest and average purchase frequency during the X-mas marketing activities. 

--* What is the total purchase amount by each category?

WITH DATA AS(
SELECT
    CASE
        when purchase_frequency <= 16 then '<= 16'
        when purchase_frequency <= 23 then '<= 23'
        else '> 23'
    end as purchase_frequency_group,
     round(avg(annual_income), 2) as avg_annual_income,
    round(avg(purchase_amount), 2) as avg_purchase_amount,   
    count(user_id) as client_count
FROM customers
GROUP BY 1
)

SELECT
    *,
    avg_purchase_amount*client_count as total_spend
from data
;

-- The highest spending amount comes from customers whose purchase frequency is between 17 and 23.

-- b. By region

SELECT
    CASE
        when purchase_frequency <= 16 then 'a. <= 16'
        when purchase_frequency <= 23 then 'b. <= 23'
        else 'c. > 23'
    end as purchase_frequency_group,
    region,
     round(avg(annual_income), 2) as avg_annual_income,
    round(avg(purchase_amount), 2) as avg_purchase_amount,   
    count(user_id) as client_count
FROM customers
GROUP BY 1,2
ORDER BY 1;


WITH DATA AS(
SELECT
    CASE
        when purchase_frequency <= 16 then 'a. <= 16'
        when purchase_frequency <= 23 then 'b. <= 23'
        else 'c. > 23'
    end as purchase_frequency_group,
    region,
     round(avg(annual_income), 2) as avg_annual_income,
    round(avg(purchase_amount), 2) as avg_purchase_amount,   
    count(user_id) as client_count
FROM customers
GROUP BY 1,2
ORDER BY 1
)

select 
    *,
    avg_purchase_amount*client_count as total_spend
from data
;

-- The West region has the most customers with a purchase frequency higher than 23 (42 customers).
-- This group also has the highest total purchase amount ($25,150).

-- The South region has the most customers with a purchase frequency between 17 and 23 (54 customers).
-- Their total purchase amount is $23,950.

-- The North region has the most customers with a purchase frequency of 16 or lower (37 customers).

-- The East region has only 6 customers, with none in the highest purchase frequency group.

-- Conclusion: Marketing should focus on keeping high-frequency customers in the West region and encouraging medium-frequency customers in the South to purchase more often.


-- 6. Do customers with higher loyalty scores purchase more frequently and spend more?

SELECT
    CASE
        when loyalty_score <= 5 then 'Score <= 5'
        else 'Score > 5'
    end as loyalty_group,
    round(avg(purchase_frequency), 2) as avg_purchase_frequency,
    round(avg(purchase_amount), 2) as avg_purchase_amount,
    count(*) as client_count
FROM customers
GROUP BY 1;

-- Customers with loyalty scores higher than 5 have a higher average purchase frequency and average purchase amount.

-- 7. Do customers with higher annual incomes tend to spend more?

select 
    avg(annual_income) as avg_annual_income, 
    min(annual_income) as min_annual_income,
    max(annual_income) as max_annual_income
from customers;

SELECT
    CASE
        when annual_income < 45000 then 'Low income'
        when annual_income < 60000 then 'Middle income'
        else 'High income'
    end as income_group,
    round(avg(purchase_amount), 2) as avg_purchase_amount,
    round(avg(purchase_frequency), 2) as avg_purchase_frequency,
    count(*) as client_count
FROM customers
GROUP BY 1
ORDER BY avg_purchase_amount DESC;

-- The High income group has the highest average purchase amount ($547.61) and frequency (~24).
-- The purchase frequency increases with income.  
-- This suggests that customers with higher incomes tend to purchase more frequently and have higher purchase amounts.
