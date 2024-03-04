-- 1. Fetching Customer Code for Croma India
SELECT * FROM gdb0041.dim_customer
where customer like "%Croma%" and market = "India";
-- 90002002  - customer code for Croma India

-- 2. Fact Sales Monthly Data is already aggregated on monthly level

-- 3. Calculating Fiscal Year from Calendar Year : CL + 4 months = AtliQ FY
-- get_fiscal_year(calendar_year)

-- 4. Fetching sales for Croma India for FY 2021
select * from fact_sales_monthly
where customer_code = 90002002
and get_fiscal_year(date) = 2021
order by date desc
limit 10000000;

-- 5. Getting product name and gross price from dim_products and fact_gross_price tables
select s.date, s.product_code, p.product, p.variant, s.sold_quantity, g.gross_price,
round(g.gross_price*s.sold_quantity, 2) as gross_amount
from fact_sales_monthly s
join dim_product p
on s.product_code = p.product_code
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = get_fiscal_year(s.date)
where customer_code = 90002002
and get_fiscal_year(date) = 2021
order by s.date desc
limit 10000000;

-- Gross sales only at month level for Fy = 2021. i.e one month must appear once
select s.date, sum(round(s.sold_quantity*g.gross_price, 2)) as gross_total
from fact_sales_monthly s
join fact_gross_price g
on g.product_code = s.product_code 
and g.fiscal_year = get_fiscal_year(s.date)
where customer_code = 90002002
and get_fiscal_year(date) = 2021
group by s.date
order by s.date desc
limit 10000000;

-- stored procedure as the same task can be required for different customer codes
-- Amazon has 2 cust_codes so to handle such cases we send coma separated list of cust_codes
select * from dim_customer where customer = "Amazon" and market = "India";
-- 90002008 , 90002016
Delimiter $$
CREATE PROCEDURE `get_monthly_gross_sales_for_customers`(cust_codes Text)
BEGIN
	select s.date, sum(round(s.sold_quantity*g.gross_price, 2)) as gross_total
    from fact_sales_monthly s
    join fact_gross_price g
    on g.product_code = s.product_code 
	and g.fiscal_year = get_fiscal_year(s.date)
	where find_in_set(s.customer_code, cust_codes) > 0
	group by s.date
	order by s.date desc;
END $$
call gdb0041.get_monthly_gross_sales_for_customers('90002008, 90002016');

-- stored procedure for getting market badge - gold/silver based on market and fiscal year

Delimiter $$
CREATE PROCEDURE `get_market_badge`(
IN in_market varchar(45),
IN in_fiscal_year year,
OUT out_badge varchar(15))
BEGIN
	declare qty int default 0;
    
    # setting default market value
    if in_market = " "  then 
		set in_market = "India";
	end if;
    
    # getting sold qty for given year and market
    select sum(s.sold_quantity) into qty
    from fact_sales_monthly s
    join dim_customer c
    on c.customer_code = s.customer_code
    where
    get_fiscal_year(s.date) = in_fiscal_year
    and c.market = in_market;
    
    # determine badge
    if qty > 5000000
		then set out_badge = "Gold";
	else set out_badge = "Silver";
    end if;
    
END $$
