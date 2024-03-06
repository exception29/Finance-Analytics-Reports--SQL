-- top markets
select market, round(sum(net_sales)/1000000, 2) as net_sales_mln
from net_sales
where fiscal_year=2021
group by market
order by net_sales_mln desc
limit 5;

-- creating stored procedure for same so that end user can access it. USer can enter fiscal_year and top count to view

-- top customers
select 
	customer, 
	round(sum(net_sales)/1000000,2) as net_sales_mln
	from net_sales s
	join dim_customer c
	on s.customer_code=c.customer_code
	where 
	s.fiscal_year=2021
	and s.market="India"
	group by customer
	order by net_sales_mln desc
	limit 5;


-- stored procedure that takes market, fiscal_year and top n as an input and returns top n customers by net sales in that given 
-- fiscal year and market
Delimiter $$
	CREATE PROCEDURE `get_top_n_customers_by_net_sales`(
        	in_market VARCHAR(45),
        	in_fiscal_year INT,
    		in_top_n INT
	)
	BEGIN
        	select 
                     customer, 
                     round(sum(net_sales)/1000000,2) as net_sales_mln
        	from net_sales s
        	join dim_customer c
                on s.customer_code=c.customer_code
        	where 
		    s.fiscal_year=in_fiscal_year 
		    and s.market=in_market
        	group by customer
        	order by net_sales_mln desc
        	limit in_top_n;
	END $$
    
    -- top products
select 
	s.product, 
	round(sum(net_sales)/1000000,2) as net_sales_mln
	from net_sales s
	where
	s.fiscal_year=2021
	and s.market="India"
	group by s.product
	order by net_sales_mln desc
	limit 5;

Delimiter $$

	CREATE PROCEDURE get_top_n_products_by_net_sales(
              in_fiscal_year int,
              in_top_n int
	)
	BEGIN
            select
                 product,
                 round(sum(net_sales)/1000000,2) as net_sales_mln
            from net_sales
            where fiscal_year=in_fiscal_year
            group by product
            order by net_sales_mln desc
            limit in_top_n;
	END $$
