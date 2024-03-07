-- Get pre invoice deductions to calculate the net sales.

select s.date, s.product_code, p.product, p.variant, s.sold_quantity, g.gross_price, 
round(g.gross_price*s.sold_quantity, 2) as gross_amount, pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p
on s.product_code = p.product_code
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = get_fiscal_year(s.date)
join fact_pre_invoice_deductions pre
on pre.customer_code = s.customer_code
and pre.fiscal_year = get_fiscal_year(s.date)
where 
-- s.customer_code = 90002002 
get_fiscal_year(date) = 2021
order by s.date desc
limit 10000000; -- other wise it will return only 1000 records by default

-- analyzing and optimizing the performance

explain analyze
select s.date, s.product_code, p.product, p.variant, s.sold_quantity, g.gross_price, 
round(g.gross_price*s.sold_quantity, 2) as gross_amount, pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p
on s.product_code = p.product_code
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = get_fiscal_year(s.date)
join fact_pre_invoice_deductions pre
on pre.customer_code = s.customer_code
and pre.fiscal_year = get_fiscal_year(s.date)
where 
-- s.customer_code = 90002002 
get_fiscal_year(date) = 2021
order by s.date desc
limit 10000000; -- other wise it will return only 1000 records by default
-- 1.2 sec 

-- analyzing and optimizing the performance
-- optimizing the query by reducinng the function call for every repeated date record in fact_Sales_monthly 
-- created separate dim_Date table
-- joining dim_date to get fiscal_year

explain analyze
select s.date, s.product_code, p.product, p.variant, s.sold_quantity, g.gross_price, 
round(g.gross_price*s.sold_quantity, 2) as gross_amount, pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_date d
on d.calendar_date = s.date
join dim_product p
on s.product_code = p.product_code
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = d.fiscal_year
join fact_pre_invoice_deductions pre
on pre.customer_code = s.customer_code
and pre.fiscal_year = d.fiscal_year
where 
-- s.customer_code = 90002002 
d.fiscal_year = 2021
order by s.date desc
limit 10000000;
-- 4 sec required

-- method 2 - optimization
-- instead of creating dim_date, directly adding the fiscal_year column in fact_Sales_monthly table.
-- 1.4M rows will be added but fiscal_year with same calculation for repeated date but we can save the join done on dim_date fy

explain analyze
select s.date, s.product_code, p.product, p.variant, s.sold_quantity, g.gross_price, 
round(g.gross_price*s.sold_quantity, 2) as gross_amount, pre.pre_invoice_discount_pct
from fact_sales_monthly s
join dim_product p
on s.product_code = p.product_code
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = s.fiscal_year
join fact_pre_invoice_deductions pre
on pre.customer_code = s.customer_code
and pre.fiscal_year = s.fiscal_year
where 
-- s.customer_code = 90002002 
s.fiscal_year = 2021
order by s.date desc
limit 10000000;
-- 0.19 sec

