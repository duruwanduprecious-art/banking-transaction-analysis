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

rred in large spikes, while expenses accumulated more steadily over time.
