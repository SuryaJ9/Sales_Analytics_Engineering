-- SQL Basics Level Analysis(1-5):

-- 1) How many total sales records are in the table.
select count(*) as total_records
from product_db;
-- total 108 records.

-- 2) Show the first 10 rows of sales data:

select * from product_db
limit 10;

-- 3) List all distinct product lines available:

select distinct product_line
from product_db;
-- 4) Find all orders where quantity ordered is greater then 50.

select * from product_db
where quantity_ordered > 50;

-- 5) Count how many orders were placed in each country.
select country,
count(distinct order_number) as total_orders
from product_db
group by country
order by total_orders desc;
-- USA,France and spain as highest total_orders.

-- 6) what is the total revenue generated?
select sum(total_revenue) as total_revenue
from product_db;

-- 7) Calculate total profit across all sales:

select sum(net_profit) as total_profit
from product_db;

-- 8) Average order values:

select 
round(sum(total_revenue) / count(distinct order_number),2)
 as avg_order_value
from product_db;

-- 9) Show revenue and profit by product line
select 
product_line,
sum(total_revenue) as revenue,
sum(net_profit)  as profit
from product_db
group by product_line
order by profit desc;

-- 10) Identify the top 5 products by total revenue

select product_name,
sum(total_revenue) as revenue
from product_db
group by product_name
order by revenue desc
limit 5;

-- 11) Show total revenue and profit by country and city.
select country,
city,
sum(total_revenue) as total_revenue,
sum(net_profit) as total_net_profit
from product_db
group by country,city
order by total_revenue,total_net_profit;

-- 12) Which country has the highest profit margin:
select country,
round(sum(net_profit) / sum(total_revenue) * 100,2) as avg_profit_margin_pct
from product_db
group by country
order by avg_profit_margin_pct desc
limit 1;

-- 13) Identify products with negative total profit:
-- Detects profit leakage and bad pricing decisions.
select product_name,
sum(net_profit) as total_profit
from product_db
group by product_name
having sum(net_profit) < 0
order by total_profit;

-- 14) Count distinct orders per product line:
select distinct product_line,
sum(sales_values) as total_sales
from product_db
group by product_line
order by total_sales desc;

-- Identifies loss-making products
-- Shows business impact thinking.

-- 15) Find the country where total revenue exceeds 100,000
select country,
sum(total_revenue)  as total_revenue
from product_db
group by country
having sum(total_revenue) > 100000
order by total_revenue desc;

-- 16) Time-based analysis is fundamental for forecasting.
select Extract(month from orderdate) as month,
sum(total_revenue) as total_revenue
from product_db
group by month
order by month;
-- foundation for forecasting & growth metrics.

-- 17) Computing the month-over-month (MoM) revenue growth.
-- growth metrics drive strategic decision.

with monthly_revenue as (
select 
DATE_TRUNC('month', orderdate) as month,
sum(total_revenue)  as revenue
from product_db
group by month;

-- 18) Rank Products by revenue within each product line
select productline,
productname,
sum(total_revenue) as revenue,
RANK() OVER (
PARTITION BY productline
ORDER BY SUM(total_revenue) DESC
) as revenue_rank
from product_db
group by productline,productname;
)
)
select 
month,
revenue,
revenue - LAG(revenue) OVER(Order BY MONTH) as mom_change,
round(
(revenue - LAG(revenue) OVER(ORDER BY month)) 
/ LAG(revenue) OVER(ORDER BY month) * 100,2) as mom_growth_pct
from monthly_revenue;


-- 18) Rank products by revenue within each product line.

SELECT
    product_line,
    product_name,
    SUM(total_revenue) AS revenue,
    RANK() OVER (
        PARTITION BY product_line
        ORDER BY SUM(total_revenue) DESC
    ) AS revenue_rank
FROM product_db
GROUP BY product_line, product_name;

-- 19) Orders where selling price < buy price.

select * from product_db
where price_each < buy_price;

--- Critical data quality & pricing check
--- often used for alerts & audits.

-- 20) Create an executive summary VIEW.

CREATE VIEW executive_sales_summary AS 
select 
product_line,
sum(total_revenue) as revenue,
sum(net_profit) as profit,
round(
sum(net_profit)/ sum(total_revenue) * 100,2) as profit_margin_pct
from product_db
group by product_line;

