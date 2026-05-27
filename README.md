# Banking Transaction Analysis Using PostgreSQL & Power BI
## Project Overview

This project analyzes personal banking transactions using PostgreSQL and Power BI. The workflow includes data cleaning in Power Query, exploratory data analysis (EDA) in SQL, and dashboard development in Power BI.

The dataset contains transaction records such as income, expenses, transaction categories, payment channels, and account balances over a one-year period. The project transforms raw banking statement data into an analysis-ready dataset and explores transaction behavior, spending patterns, and financial activity over time.

The final deliverable is an interactive Power BI dashboard for visualizing financial performance and transaction trends.

---

# Project Objectives

The objectives of this project are to:

- Clean and transform raw banking transaction data into an analysis-ready dataset
- Analyze income and expense trends over time
- Identify the highest spending categories
- Evaluate monthly cashflow performance
- Quantify transaction frequency and spending behavior
- Detect high-value and recurring transactions
- Build an interactive dashboard for financial monitoring and reporting

---

# Business Questions

This analysis seeks to answer the following questions:

1. What is the overall financial position based on income and expenses?
2. Which transaction categories contribute most to total spending?
3. Which months recorded the highest and lowest cashflows?
4. What days experience the highest spending activity?
5. Which transaction categories occur most frequently?
6. Are there recurring low-value expenses?
7. Which transactions exceed normal spending behavior?
8. Which transaction types dominate financial activity?

---

# Tools Used

| Tool | Purpose |
|---|---|
| Power Query | Data cleaning and transformation |
| PostgreSQL | SQL querying and exploratory data analysis |
| Power BI | Dashboard creation and visualization |

---

# Dataset Information

- Total Rows: 680
- Total Columns: 14
- Date Range:
  - First Transaction: 2025-06-27
  - Last Transaction: 2026-05-07

The dataset contains banking transaction records including:
- Transaction dates
- Payment channels
- Transaction descriptions
- Income and expense amounts
- Account balances
- Transaction categories

---

# Data Cleaning Process

The raw banking statement dataset required extensive cleaning and transformation before analysis could be performed. The dataset contained fragmented transaction rows, inconsistent formats, missing values, and unstructured transaction descriptions.

Data cleaning was performed in Power Query using the following steps:

## 1. Data Consolidation
- Imported the three separate bank statement tables into Power Query
- Appended all tables into a single unified dataset for analysis

## 2. Handling Fragmented Rows
- Identified continuation rows containing incomplete transaction information
- Used:
  - Fill Down
  - Group By
  - Text.Combine
to merge fragmented transaction descriptions into complete records

## 3. Removing Unnecessary Rows
- Removed blank and invalid rows
- Excluded closing balance rows and non-transaction entries

## 4. Data Type Standardization
Converted columns into appropriate data types:
- Transaction dates → Date type
- Pay In / Pay Out / Amount / Balance → Decimal numbers
- Transaction categories and channels → Text

## 5. Null Value Handling
- Imputed missing values by replacing null in:
  - Pay In
  - Pay Out
with `0` to ensure mathematical consistency during aggregations

## 6. Feature Engineering
Created additional analytical columns to support time-series analysis:
- Year
- Month Name
- Month Number
- Quarter
- Day Name

## 7. Transaction Classification
Created custom transaction classifications including:

### Transaction Type
- Credit
- Debit

### Transaction Category
- Transfer
- Airtime
- Bank Charges
- Others

These categories were derived from transaction descriptions using conditional logic.

## 8. Text Cleaning and Standardization
- Cleaned inconsistent transaction descriptions
- Reduced excessively long transaction detail strings
- Standardized text formatting for easier categorization and analysis

## 9. Final Validation
- Verified row counts after transformation
- Confirmed date consistency and transaction ranges
- Checked for duplicate and missing records

The cleaned dataset was then exported as a .csv and loaded into PostgreSQL for SQL-based exploratory data analysis and dashboard preparation.

---

# SQL Exploratory Data Analysis (EDA)

Exploratory Data Analysis (EDA) was performed in PostgreSQL to analyze transaction behavior, financial performance, spending trends, and category-level activity.

The analysis focused on identifying:
- Income and expense trends
- Monthly financial performance
- Spending behavior
- Transaction frequency
- High-value transactions
- Category contribution to overall expenses

---

# Dataset Overview

```sql
SELECT COUNT(*) AS total_transactions
FROM bank_transactions;
```

## Findings
- The dataset contains **680 transactions** across **14 columns**.
- Transactions span from **2025-06-27** to **2026-05-07**.

---

# Total Income vs Total Expenses

```sql
SELECT
    SUM(pay_in) AS total_income,
    SUM(pay_out) AS total_expenses
FROM bank_transactions;
```

| Metric | Amount |
|---|---|
| Total Income | ₦1,214,190.22 |
| Total Expenses | ₦1,109,593.32 |

## Insight
- Total income exceeded total expenses by **₦104,596.90** (overall saving rate of **8.6%**), indicating an overall positive cashflow during the analysis period.

---

# Monthly Transaction Volume

```sql
SELECT
    month_name,
    month,
    COUNT(*) AS transaction_volume
FROM bank_transactions
GROUP BY month_name, month
ORDER BY month;
```

## Insight
- December recorded the highest transaction activity with **83 transactions**.
- June recorded the lowest transaction volume with **10 transactions**.
- Transaction activity remained relatively consistent across most months.

---

# Monthly Financial Summary

```sql
WITH monthly_summary AS (
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
```

## Insight
- The account experienced intense financial stress across four distinct periods January (**-₦46k**), April (**-₦99,725.55**), August(**-₦33k**), November (**-₦52k**) with April being the highest. This indicates periods where expenses exceeded income.
- February(**+₦65k**) and May(**+₦81k**) recorded the strongest positive cashflows.

---

# Highest Spending Days

```sql
SELECT
    day_name,
    SUM(pay_out) AS total_spending
FROM bank_transactions
GROUP BY day_name
ORDER BY total_spending DESC;
```

| Day | Total Spending |
|---|---|
| Monday | ₦536,416.92 |
| Tuesday | ₦207,947.05 |
| Wednesday | ₦174,323.31 |

## Insight
- Monday accounted for the highest spending activity.
- Spending gradually declined toward the end of the workweek.
- Most transfers and bill payments likely occurred early in the week.

---

# Transaction Category Analysis

## Most Frequent Categories

```sql
SELECT
    transaction_category,
    COUNT(*) AS transaction_count
FROM bank_transactions
GROUP BY transaction_category
ORDER BY transaction_count DESC;
```

| Category | Transactions |
|---|---|
| Transfer | 242 |
| Bank Charges | 223 |
| Airtime | 165 |

## Insight
- Transfer transactions dominated user activity.
- Bank charges occurred very frequently despite low individual values.
- Airtime purchases were frequent but relatively low-value.

---

# Total Spending by Category

```sql
SELECT
    transaction_category,
    SUM(pay_out) AS total_spending
FROM bank_transactions
WHERE transaction_type = 'Debit'
GROUP BY transaction_category
ORDER BY total_spending DESC;
```

| Category | Total Spending |
|---|---|
| Transfer | ₦967,147.86 |
| Airtime | ₦136,850.00 |
| Bank Charges | ₦4,073.64 |
| Others | ₦1,521.82 |

## Insight
- Transfer transactions accounted for approximately **87%** of total expenses.
- Transfers were the primary driver of outgoing cashflow.

---

# Largest Expense by Category

```sql
SELECT
    transaction_category,
    MAX(pay_out) AS largest_expenses
FROM bank_transactions
WHERE transaction_type = 'Debit'
GROUP BY transaction_category
ORDER BY largest_expenses DESC;
```

| Category | Largest Expense |
|---|---|
| Transfer | ₦25,026.88 |
| Airtime | ₦3,000.00 |
| Bank Charges | ₦96.00 |
| Others | ₦1,075.00 |

## Insight
- Transfer transactions contained the highest-value expenses.
- Bank charges remained consistently low-value transactions.

---

# Spending Segmentation Using CASE WHEN

```sql
SELECT
transaction_category,
CASE
    WHEN transaction_amount < 5000 THEN 'Low Spend'
    WHEN transaction_amount BETWEEN 5000 AND 20000 THEN 'Medium Spend'
    ELSE 'High Spend'
END AS spending_segment,
COUNT(*) AS total_transactions
FROM bank_transactions
WHERE transaction_type = 'Debit'
GROUP BY transaction_category, spending_segment
ORDER BY total_transactions DESC;
```

## Insight
- Most transactions fell under the **Low Spend** category.
- High-value transactions were rare and occurred mostly within transfer activities.
- Transfer transactions showed the widest spending distribution.

---

# Cumulative Transaction Analysis

```sql
CREATE TEMP TABLE temp_cumulative_transaction AS
SELECT
    transaction_date,
    transaction_category,
    transaction_amount,
    SUM(transaction_amount)
    OVER(ORDER BY transaction_date) AS running_total,
    
    SUM(transaction_amount)
    OVER() AS grand_total
FROM bank_transactions
WHERE transaction_type = 'Debit';
```

## Insight
- Transfer transactions dominated cumulative expense growth.
- Airtime and bank charges contributed gradually due to smaller transaction values.
- A small number of transfer transactions accounted for a disproportionately large share of expenses.

---

# Cumulative Cashflow Analysis

```sql
CREATE TEMP TABLE temp_cumulative_cashflow AS
SELECT
    transaction_date,
    transaction_type,
    transaction_amount,
    
    SUM(transaction_amount)
    OVER(PARTITION BY transaction_type ORDER BY transaction_date) AS running_total,
    
    SUM(transaction_amount)
    OVER(PARTITION BY transaction_type) AS grand_total
FROM bank_transactions
WHERE transaction_type IN ('Credit', 'Debit');
```

## Insight
- Debit transactions dominated transaction frequency throughout the dataset.
- Credit transactions occurred less frequently but contributed larger individual values.
- Income accumulation occurred in large spikes, while expenses accumulated more steadily over time.
