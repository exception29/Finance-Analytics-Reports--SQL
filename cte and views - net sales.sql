-- Calculating Net Sales for getting top markets, products and customers

-- CTE for getting pre_invoice data. 
-- As gross_amount is derived field and can't be used in same query so we make use of CTE. And then from cte use the values 

with preinv as
	(
		select s.date, s.fiscal_year, s.customer_code, s.product_code, p.product, c.market, p.variant, s.sold_quantity, g.gross_price, 
		round(g.gross_price*s.sold_quantity, 2) as gross_amount, pre.pre_invoice_discount_pct
		from fact_sales_monthly s
        join dim_customer c
        on s.customer_code = c.customer_code
		join dim_product p
		on s.product_code = p.product_code
		join fact_gross_price g
		on g.product_code = s.product_code 
		and g.fiscal_year = s.fiscal_year
		join fact_pre_invoice_deductions pre
		on pre.customer_code = s.customer_code
		and pre.fiscal_year = s.fiscal_year
		order by s.date desc
	)
    select *,
    (gross_amount - pre_invoice_discount_pct*gross_amount) as net_invoice_sales
    from preinv;
    
-- this CTE/ pre_invoice data will be further required for calculating the nes sales, gm, etc 
-- but CTE can't be used again after this scope.
-- So, we write same logic in view. View can be used multiple times and generates table at run time.

create view `sales_pre_invoice` as
select
	s.date, 
	s.fiscal_year,
	s.customer_code,
    s.product_code, 
	p.product, 
	c.market,
	p.variant, 
	s.sold_quantity, 
	g.gross_price,
	ROUND(s.sold_quantity*g.gross_price,2) as gross_amount,
	pre.pre_invoice_discount_pct
	from fact_sales_monthly s
	join dim_customer c 
		on s.customer_code = c.customer_code
	join dim_product p
        	on s.product_code=p.product_code
	join fact_gross_price g
    		on g.fiscal_year=s.fiscal_year
    		and g.product_code=s.product_code
	join fact_pre_invoice_deductions as pre
        	on pre.customer_code = s.customer_code and
    		pre.fiscal_year=s.fiscal_year
	order by s.date desc;
    
    
SELECT 
	*,
	(gross_amount-pre_invoice_discount_pct*gross_amount) as net_invoice_sales
from sales_pre_invoice;
-- sales_pre_invoice is view

-- using pre_invocie view, joining table to get post_invoice data
SELECT 
	s.date, s.fiscal_year,
	s.customer_code, s.market,
	s.product_code, s.product, s.variant,
	s.sold_quantity, s.gross_price,
	s.pre_invoice_discount_pct,
	(s.gross_amount-s.pre_invoice_discount_pct*s.gross_amount) as net_invoice_sales,
	(po.discounts_pct+po.other_deductions_pct) as post_invoice_discount_pct
from sales_pre_invoice s
join fact_post_invoice_deductions po
on
po.customer_code = s.customer_code
and po.product_code = s.product_code
and po.date = s.date;

-- using above query creating a view for net invoice and post_deductions
-- sales_post_deductions view
create view `sales_post_deductions` as
	select 
    	    s.date, s.fiscal_year,
            s.customer_code, s.market,
            s.product_code, s.product, s.variant,
            s.sold_quantity, s.gross_amount,
            s.pre_invoice_discount_pct,
            (s.gross_amount-s.pre_invoice_discount_pct*s.gross_amount) as net_invoice_sales,
            (po.discounts_pct+po.other_deductions_pct) as post_invoice_discount_pct
	from sales_pre_invoice s
	join fact_post_invoice_deductions po
		on po.customer_code = s.customer_code and
   		po.product_code = s.product_code and
   		po.date = s.date;


-- calculating net sales from post_invoice view
select *,
net_invoice_sales*(1-post_invoice_discount_pct) as net_sales
from sales_post_deductions;

-- creating view for net sales calculation from above query
create view `net_sales` as
	select 
            *, 
    	    net_invoice_sales*(1-post_invoice_discount_pct) as net_sales
	from sales_post_deductions;
    
select * from net_sales;

-- fetching data from views:
select * from gross_sales;

select * from sales_pre_invoice;

select * from sales_post_deductions;

select * from net_sales; 


