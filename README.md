# Finance-Analytics-Reports - SQL

## SQL Joins, Functions, Views, Stored Procedures: 

## *<u>financial_analytics.sql:<u/>*

Generated Excel Reports for:

1. Product Level Monthly Gross Sales of Croma in India FY 2021 2.
2. Monthly Gross Sales Of Croma in India for FY 2021

- For generating Report of Croma at India market, fetched the customer code for Croma India.
- Calculated Fiscal Year from calendar year which is Sept to August for AtliQ.
- Performed Joins to get remaining columns like product details, gross sales, etc.
- Created a Stored Procedure to generalize the same query to generate Monthly Gross Sales reports for any desired customer, market and Fiscal year.
- Also wrote a query to allocate a Gold or Silver badge to the markets based on gross sales.
- This Project helped understand the Profit And Loss Statement and Finance Operations.

## *<u>cte and views - net sales.sql:<u/>*

Created Views for calculating Pre-Invoice Deductions, Post Invoice Deductions and Net Sales.

## *<u>net-invoice query optimization:</u>
Approach 1:

Optimizing the query by reducing the function call for every repeated date record in fact_sales_monthly 
Created separate dim_date table and joined dim_date to get fiscal_year.
This optimized the performance by 50%.

Approach 2:

Instead of creating dim_date, directly adding the fiscal_year column in fact_sales_monthly table.
1.4M rows will be added. Fiscal_year with same calculation for repeated date but we can save the join done on dim_date FY
This increased the efficiency by 80%.

## *<u>top markets products customers.sql:<u/>*

Implemented Stored Procedures to Find Top N Customers, Markets and Products.

This project helped to understand the Profit and Loss Statement.

