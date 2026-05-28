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

**1. Data Consolidation** 
- Imported the three separate bank statement tables into Power Query
- Appended all tables into a single unified dataset for analysis

**2. Handling Fragmented Rows** 
- Identified continuation rows containing incomplete transaction information
- Used:
  - Fill Down
  - Group By
  - Text.Combine
to merge fragmented transaction descriptions into complete records

**3. Removing Unnecessary Rows** 
- Removed blank and invalid rows
- Excluded closing balance rows and non-transaction entries

**4. Data Type Standardization** 

Converted columns into appropriate data types:

- Transaction dates → Date type
- Pay In / Pay Out / Amount / Balance → Decimal numbers
- Transaction categories and channels → Text

**5. Null Value Handling**
- Imputed missing values by replacing null in:
  - Pay In
  - Pay Out
with `0` to ensure mathematical consistency during aggregations

**6. Feature Engineering**

Created additional analytical columns to support time-series analysis:

- Year
- Month Name
- Month Number
- Quarter
- Day Name

**7. Transaction Classification**

Created custom transaction classifications including:

**Transaction Type**
- Credit
- Debit

**Transaction Category**
- Transfer
- Airtime
- Bank Charges
- Others

These categories were derived from transaction descriptions using conditional logic.

**8. Text Cleaning and Standardization**
- Cleaned inconsistent transaction descriptions
- Reduced excessively long transaction detail strings
- Standardized text formatting for easier categorization and analysis

**9. Final Validation**
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

## 1. Dataset Overview

```sql
SELECT COUNT(*) AS total_transactions
FROM bank_transactions;
```

```sql
SELECT MIN(transaction_date) AS first_transaction
MAX(transaction_date) AS last_transaction 
FROM bank_transactions;
```

### Findings
- The dataset contains **680 transactions** across **14 columns**.
- Transactions span from **2025-06-27** to **2026-05-07**.

---

## 2. Total Income vs Total Expenses

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

### Insight
- Total income exceeded total expenses by **₦104,596.90**, resulting in an overall positive net cashflow position during the analysis period.
- The account maintained an estimated savings rate of approximately **8.6%**, indicating moderate financial retention after expenses.

---

## 3. Monthly Transaction Volume

```sql
SELECT
    month_name,
    month,
    COUNT(*) AS transaction_volume
FROM bank_transactions
GROUP BY month_name, month
ORDER BY month;
```

### Insight
- **December** recorded the highest transaction activity with **83 transactions**, likely driven by increased seasonal spending and transfers.
- **June** recorded the lowest transaction activity with **10 transactions**, representing the beginning of the transaction timeline.
- Transaction activity remained relatively stable across most months.

---

## 4. Monthly Financial Summary

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

### Insight
- **April** recorded the highest negative cashflow at **-₦99,725.55**, indicating the largest monthly financial deficit.
- **February** and **May** recorded the strongest positive net cashflows.
- Negative net cashflow also occurred in:
  - January (**-₦46,148.18**)
  - July (**-₦17,549.70**)
  - August (**-₦33,139.01**)
  - November (**-₦52,098.17**)

These periods reflect months where expenses exceeded income inflows.

---

## 5. Highest Spending Days

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
| Thursday | ₦106,655.40 |
| Friday | ₦84,250.64 |

### Insight
- Monday recorded the highest spending activity, accounting for approximately **48.3% of total annual outflows**.
- Spending gradually declined toward the end of the workweek hitting its absolute lowest baseline on Friday.
- This pattern suggests that major transfers, bill payments, and recurring obligations were typically executed at the beginning of the week.

---

## 6. Transaction Category Analysis

### Most Frequent Categories

```sql
SELECT
    transaction_category,
    COUNT(*) AS transaction_count,
    SUM(pay_out) AS total_spending,
    MAX(pay_out) AS single_largest_expense
FROM bank_transactions
WHERE transaction_type = 'Debit'
GROUP BY transaction_category
ORDER BY total_spending DESC;
```

| Category | Transactions_count | Total_spending | Single_largest_expense |
|---|---|---|---|
| Transfer | 242 | ₦967,147.86 | 25,026.88 |
| Airtime | 165 | ₦136,850.00 | 3000 |
| Bank Charges | 223 | ₦4,073.64 | 96.00 |
| Others | 12 | ₦1,521.82 | 1075.00 |

---

### Insight
- Transfer transactions dominated overall spending behavior, accounting for approximately **87.1% of all total expenses (₦967,147.86)** .
- Transfer transactions also contained the highest-value individual expenses.
- Bank charges occurred at very high frequency (**223 transactions**) but contributed minimally to total spending value, indicating recurring low-cost operational charges.
- Airtime transactions displayed high frequency **(165 records)** with moderate cumulative financial impact **(₦136,850.00)**.

---

## 7. Spending Segmentation Using CASE WHEN

```sql
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
ORDER BY total_transactions DESC;
```

| Category | Spending_segment | Total_transactions |
|---|---|---|
| Bank Charges | Low Spend | 223 |
| Airtime | Low Spend | 162 |
| Transfer | Low Spend | 161 |
| Transfer | Medium Spend | 67 |
| Others | Low Spend | 12 |
| Transfer | High Spend | 12 |


## Transactions Greater Than 3 Times Average Debit Amount
```sql
SELECT
    transaction_date, 
    transaction_category,
    transaction_amount,
    details
FROM bank_transactions
WHERE transaction_type = 'Debit'
AND transaction_amount  > (SELECT AVG(transaction_amount) * 3
FROM bank_transactions
WHERE transaction_type = 'Debit'
)
ORDER BY transaction_amount DESC
```

### Insight
- Most transfer transactions (**162 out of 242**) fell within the low-spend tier, indicating frequent small-value transfers. However, a significant portion of total financial outflow was concentrated within medium- (**67**) and high-spend (**12**) transfer transactions.
- A deeper outlier analysis of transactions exceeding three times the average debit amount revealed that all major spending spikes were initially classified under the generic **Transfer** category.
 - Further keyword analysis of transaction descriptions uncovered two dominant spending behaviors:
    - **High-Spend Transfers (>₦15k):** Is primarily linked to professional development and career-related investments processed through platforms such as Paystack, including payments for SQL and Data Analytics training programs.
    - **Medium-Spend Transfers (₦5k–₦15k):** Mostly associated with lifestyle and utility-related settlements routed through mobile wallet platforms such as OPay, covering expenses such as food purchases, transportation,  retail payments, and household items.

---

## 8. Cumulative Spending Progression

```sql
DROP TABLE IF EXISTS temp_cumulative_transaction;

CREATE TEMP TABLE temp_cumulative_transaction AS
SELECT
    transaction_date,
    transaction_category,
    transaction_amount,
    SUM(transaction_amount)
    OVER(
        ORDER BY transaction_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total,
    SUM(transaction_amount) OVER() AS grand_total
FROM bank_transactions
WHERE transaction_type = 'Debit'

SELECT
    transaction_date,
    transaction_category,
    transaction_amount
ROUND((running_total/grand_total)*100,2)
As cumulative_transaction
FROM temp_cumulative_transaction
```

### Insight
- Cumulative spending analysis showed that the majority of debit spending occurred within the earlier months of the analysis period.
- By **April 28**, over **97%** of total annual expenses had already been accumulated, indicating a slowdown in spending activity afterward.

---

# Dashboard Preview

## Financial Overview Dashboard

![Financial Overview](screenshots/dashboard1.png)

## Spending Analysis Dashboard

![Spending Analysis](screenshots/dashboard2.png)

---

# Recommendations

Based on the SQL analysis and dashboard insights, the following recommendations were identified:

**1. Reduce Transfer Spending Concentration;**
Transfer transactions accounted for approximately **87.1% of total expenses**, making them the dominant driver of cash outflows. Implementing stricter transfer budgeting and periodic spending reviews could help improve expense control and reduce excessive capital leakage.

**2. Monitor High-Value Transfer Activity:**
Outlier analysis revealed that the largest debit spikes originated from transfer transactions. Establishing transaction thresholds and monitoring unusually large transfers can improve financial planning and cashflow stability.

**3. Improve Monthly Cashflow Stability:**
Several months, including January, April, July, August, and November, recorded negative net cashflows where expenses exceeded income. Creating monthly spending limits and aligning expenses more closely with expected income inflows may reduce recurring deficits.

**4. Review Recurring Bank Charges:**
Although bank charges contributed minimally to total spending value, they occurred at very high frequency **(223 transactions)**. Periodic reviews of banking fees and transaction charges could help minimize unnecessary operational costs over time.

**5. Optimize Early-Month Spending Behavior:**
Monday alone accounted for nearly half of all annual spending activity, suggesting heavy front-loaded weekly expenses. Distributing major payments more evenly across the week may improve short-term liquidity management.

**6. Track Lifestyle vs Investment Spending Separately:**
Transaction text analysis showed that high-value transfers were largely linked to professional development and career investments, while medium-value transfers were associated with lifestyle spending. Separating these spending categories more explicitly would improve financial tracking and budgeting accuracy.

---

# Future Improvements

Possible future enhancements include:
- Forecasting future expenses
- Automated ETL pipelines
- Real-time dashboard integration

# Conclusion

This project demonstrates an end-to-end data analytics workflow involving data cleaning, SQL-based exploratory analysis, business insight generation, and dashboard development using Power BI.
