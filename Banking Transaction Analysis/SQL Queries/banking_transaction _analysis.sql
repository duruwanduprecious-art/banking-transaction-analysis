-- Creating table
CREATE TABLE bank_transactions(
Transactions_id SERIAL PRIMARY KEY,
Transaction_date DATE,
Value_date DATE,
Channel VARCHAR(100),
Details TEXT,
Pay_in NUMERIC(12,2),
Pay_out NUMERIC(12,2),
Balance NUMERIC(12,2),
Transaction_type VARCHAR(20),
Transaction_amount NUMERIC(12,2),
Transaction_category VARCHAR(100),
Year INT,
Month INT,
Month_name VARCHAR (20),
Day_name VARCHAR(20),
Quarter VARCHAR(5)
);

-----------------------------------------------------------
-----------------------------------------------------------

-- Importing the dataset
Copy bank_transactions(
transaction_date,
value_date,
channel,
details,
pay_in,
pay_out,
balance,
transaction_type,
transaction_amount,
transaction_category,
year,
month,
month_name,
day_name,
quarter
)
FROM 'C:\Banking Transaction Analysis\Cleaned Dataset\Cleaned_bank_transactions.csv'
DELIMITER ','
CSV HEADER;

------------------------------------------------------------
------------------------------------------------------------

-- Dataset Preview
SELECT *
FROM bank_transactions
LIMIT 20

SELECT COUNT(*) AS total_transactions
FROM bank_transactions

SELECT MIN(transaction_date) AS first_transaction,
MAX(transaction_date) AS last_transaction
FROM bank_transactions;

SELECT DISTINCT transaction_type
FROM bank_transactions;

SELECT DISTINCT transaction_category
FROM bank_transactions;

----------------------------------------------------------
----------------------------------------------------------

-- Verifying Total Income vs Total Expenses
SELECT 
    SUM(pay_in) AS total_income,
    SUM(pay_out) AS total_expenses
FROM bank_transactions;

---------------------------------------------------------
---------------------------------------------------------

-- Monthly Transaction Volume
SELECT 
month_name,
month,
COUNT(*) AS transaction_volume
FROM bank_transactions
GROUP BY month_name, month
ORDER BY month;

----------------------------------------------------------
----------------------------------------------------------

-- Analyzing Monthly Spending Trend
SELECT 
month_name,
month,
SUM(pay_out) AS monthly_expense
FROM bank_transactions
GROUP BY month_name, month
ORDER BY month;

-----------------------------------------------------------
-----------------------------------------------------------

-- Verifying Monthly Income Trend
SELECT 
month_name,
month,
SUM(pay_in) AS monthly_income
FROM bank_transactions
GROUP BY month_name, month
ORDER BY month;

----------------------------------------------------------
----------------------------------------------------------

-- Monthly Financial Summary
WITH monthly_summary AS(
    SELECT 
        month_name,
        month,
        SUM(pay_in) AS monthly_income,
        SUM(pay_out) AS monthly_expense
	FROM bank_transactions	
	GROUP BY month_name, month
)
SELECT *,
monthly_income - monthly_expense AS net_cashflow
FROM monthly_summary
ORDER BY month;

------------------------------------------------------------
------------------------------------------------------------

-- Highest Spending Days
SELECT
day_name,
SUM(pay_out) AS total_spending
FROM bank_transactions
GROUP BY day_name
ORDER BY total_spending DESC;

-----------------------------------------------------------
-----------------------------------------------------------

-- Transaction Volume by Type
SELECT 
transaction_type,
COUNT(*) As total_transactions,
SUM(transaction_amount) AS total_amount
FROM bank_transactions
GROUP BY transaction_type;

-----------------------------------------------------------
-----------------------------------------------------------

-- Transaction Category Analysis
SELECT
    transaction_category,
    COUNT(*) AS transaction_count,
	SUM(pay_out) AS total_spending,
	MAX(pay_out) AS single_largest_expenses
FROM bank_transactions
WHERE transaction_type = 'Debit'
GROUP BY transaction_category
ORDER BY total_spending DESC;

-------------------------------------------------------------
-------------------------------------------------------------

-- Analyzing the category with total spending above average
WITH category_spending AS (
    SELECT 
	    transaction_category,
		SUM(pay_out) AS total_spent
	FROM bank_transactions
	GROUP BY transaction_category
)
SELECT *
FROM category_spending
WHERE total_spent > (SELECT AVG(total_spent)
FROM category_spending);

-------------------------------------------------------------
-------------------------------------------------------------

-- Transactions that are greater than 3 times of average debit amount
SELECT
    transaction_date,
	transaction_category,
	transaction_amount,
	details
FROM bank_transactions
WHERE transaction_type = 'Debit'
AND transaction_amount > (SELECT AVG(transaction_amount) * 3 
FROM bank_transactions WHERE transaction_type = 'Debit'
)
ORDER BY transaction_amount DESC

-------------------------------------------------------------
-------------------------------------------------------------

--- Expenses Segmentation Using CASE WHEN
SELECT 
transaction_category,
CASE
    WHEN transaction_amount < 5000 THEN 'Low Spend'
	WHEN transaction_amount BETWEEN 5000 AND 15000 THEN 'Medium Spend'
	ELSE 'High Spend'
	END AS spending_segment,
	COUNT(*) AS total_transactions
FROM bank_transactions
WHERE transaction_type = 'Debit'
GROUP BY transaction_category, spending_segment
ORDER BY total_transactions DESC
	
-----------------------------------------------------------
-----------------------------------------------------------

Drop Table if Exists temp_cumulative_transaction;

CREATE TEMP TABLE temp_cumulative_transaction AS
SELECT 
    transaction_date,
    transaction_category,
    transaction_amount,
    SUM(transaction_amount) OVER(ORDER BY transaction_date) AS running_total,
	SUM(transaction_amount) OVER() AS grand_total
FROM bank_transactions
WHERE transaction_type = 'Debit';

SELECT 
    transaction_date,
    transaction_category,
    transaction_amount,
ROUND((running_total/grand_total)* 100,2) AS cumulatitve_trasaction
FROM temp_cumulative_transaction

---------------------------------------------------------
---------------------------------------------------------


-- Creating Views for Dashboard Development on Power Bi

---------------------------------------------------------
--------------------------------------------------------

CREATE OR REPLACE VIEW
banking_transaction AS
SELECT
    transaction_date,
    year,
    month_name,
    month,
	day_name,
    channel,
	
    transaction_type,
	transaction_category,
	pay_in,
	pay_out,
    transaction_amount,
    CASE
        WHEN transaction_amount < 5000 THEN 'Low Spend'
	    WHEN transaction_amount BETWEEN 5000 AND 15000 THEN 'Medium Spend'
	    ELSE 'High Spend'
	END AS spending_segment
FROM bank_transactions;


SELECT *
FROM banking_transaction

---------------------------------------------------------
---------------------------------------------------------
