SELECT * from walmart;

SELECT DISTINCT(payment_method) ,
count(*)
from walmart 
GROUP by 1;


SELECT count(*) FROM walmart;

SELECT DISTINCT(branch)from walmart;

SELECT max(quantity) from walmart;
SELECT distinct category from walmart;

--Business problems:
/*1. Analyze Payment Methods and Sales
 Question: What are the different payment methods, and how many transactions and
items were sold with each method?*/

SELECT DISTINCT(payment_method) ,
count(*) as Total_transcations,
sum(quantity) as Total_items_sold
from walmart 
GROUP by payment_method ;

-- 2. Identify the Highest-Rated Category in Each Branch
--   Question: Which category received the highest average rating in each branch?
SELECT * 
from
( SELECT category,
			branch,
		(avg(rating))as avg_ratings,
		rank() over(partition by branch order by avg(rating) desc) as rank
		FROM walmart
		group by category , branch
)		

where rank =1 ;


-- 3. Determine the Busiest Day for Each Branch
-- Question: What is the busiest day of the week for each branch based on transaction volume?

SELECT * from 
(SELECT branch,
			count(*) as transcation,
		to_char(to_date(date ,'DD/MM/YY'),'day') AS formatted_dates,
		rank() over(partition by branch order  by count(*) DESC) as rank
		from walmart
		group by branch ,3
)
 where rank =1;	


-- 4. Calculate Total Quantity Sold by Payment Method
-- Question: How many items were sold through each payment method?

select payment_method,
		sum(quantity) as Total_quantity_sold
		from walmart
		group by 1;


-- 5. Analyze Category Ratings by City
-- Question: What are the average, minimum, and maximum ratings for each category in each city?

SELECT 
		avg(rating) as avg_ratings,
		min(rating) as min_ratings,
		max(rating) as max_ratings,
	    category,
		 city
	from walmart
	group by 4,5;
		

-- 6. Calculate Total Profit by Category
-- Question: What is the total profit for each category, ranked from highest to lowest?

select category,
		sum(total* profit_margin) as Total_profit
		from walmart
		 group by  1 
		 order by 2 desc;


-- 7. Determine the Most Common Payment Method per Branch
-- Question: What is the most frequently used payment method in each branch?
select * from 
		(SELECT branch ,
		payment_method,
		count(*) as total_transactions,
		rank() over(partition by branch order by count(*) desc ) as rank
		from walmart
		group by 1,2)
		
where rank = 1;

-- 8. Analyze Sales Shifts Throughout the Day
-- Question: How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

select 
	case
		when extract (hour from (time::time)) < 12 THEN 'Morning'
		WHEN  extract (hour from (time::time)) BETWEEN 12 and 17 then 'Afternoon'
		ELSE 'Evening'
	END day_time,
	count(*) as total_trans

from walmart
group by 1;


-- 9. Identify Branches with Highest Revenue Decline Year-Over-Year
-- Question: Which branches experienced the largest decrease in revenue compared to the previous year?

select*, 
EXTRACT(year from to_date(date ,'DD/MM/YY')) AS fromatted_date
from walmart


with rev_2022 
as
(select 
	branch,
	sum(total) as revenue
	from walmart
		 where EXTRACT(year from to_date(date ,'DD/MM/YY'))  =2022

	group by 1
),
 rev_2023 
 AS
(	select 
	branch,
	sum(total) as revenue
	from walmart
		 where EXTRACT(year from to_date(date ,'DD/MM/YY'))  =2023

	group by 1
)
SELECT ls_sales.branch,
		ls_sales.revenue as last_year_revenue,
		cr_sales.revenue as current_year_revenue,
		round((ls_sales.revenue - cr_sales.revenue)::numeric/ ls_sales.revenue::numeric *100 ,2) as revenue_decline_ratio
from rev_2022 as ls_sales
join rev_2023 as cr_sales
on ls_sales.branch = cr_sales.branch
where ls_sales.revenue > cr_sales.revenue
order by 4 desc limit 5;
