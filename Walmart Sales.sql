Use walmart_sales;

select * from walmart;

-- Business Problems--
-- Q1 Find the different payments method and number of transactions and quantity sold--

select payment_method, count(*) as number_of_transactions,
sum(quantity) as quantity_sold
from walmart
group by payment_method;

-- Q2 Identify the highest-rated category in each branch,
-- displaying the branch, category and average rating

select * from
(select branch, category , avg(rating) as average_rating,
rank() over (partition by branch order by avg(rating) desc) as rank_num
from walmart
group by branch,category) a
where a.rank_num=1;

-- Q3 Identify busiest day for each branch based on number of transactions

select t.branch,t.day_name,t.no_transactions,t.rank_num
from (select branch,
DAYNAME(str_to_date(date, '%d/%m/%y')) as day_name,
count(*) as no_transactions,
rank() over (partition by branch order by count(*) desc) as rank_num
from walmart
group by branch,day_name)t
where rank_num=1;

-- Q4 Determine average, minimum and maximum rating of category 
-- for each city,list city, average_rating,min_rating and max_rating
select city, category ,max(rating) as max_rating,
min(rating) as min_rating,avg(rating) as avg_rating
from walmart
group by city,category;

-- Q5 Calculate the total profit for each category by considering total profit as
-- (unit price * quantity * profit margin).
-- List category and total_profit,ordered from highest to lowest profit

select category,sum(total) as total_revenue,
round(sum(total*profit_margin),2) as total_profit
from walmart 
group by category
order by sum(total*profit_margin) desc;

-- Q6 Determine the most common payment method for each branch--
-- Display Branch and the preferred payment method.

select t.branch,t.payment_method,t.total_payment_method,t.rank_num from
(select branch, payment_method, count(payment_method) as total_payment_method,
Rank() over (partition by branch order by count(payment_method)desc ) as rank_num
from walmart
group by branch,payment_method)t
where rank_num =1;

-- Q7 Categorize sales into 3 group MORNING, AFTERNOON, EVENING --
-- Find out which of the shift and number of invoices --

select branch,
Case 
     when Hour(cast( time as time)) < 12 then 'Morning' 
     when hour(cast( time as time)) between 12 and 17 then 'Afternoon'
     else 'Evening'
end day_time,count(*) 
from walmart
group by branch,day_time
order by branch,count(*) desc;

-- Q8 Identify 5 branch with highest decrease ratio in
-- revenue compare to last year (current 2023 and last year 2022)-- 

with revenue_2022 as (select branch,sum(total) as revenue_2022
from walmart
where Year(str_to_date(date,'%d/%m/%y')) = 2022
group by branch
order by branch),
 revenue_2023 as (select branch,sum(total) as revenue_2023
from walmart
where Year(str_to_date(date,'%d/%m/%y')) = 2023
group by branch
order by branch)

select ls.branch,
ls.revenue_2022 as last_year_revenue,
cs.revenue_2023 as current_year_revenue,
ROUND((ls.revenue_2022-cs.revenue_2023)*100/ls.revenue_2022,2) as decrease_ratio
from revenue_2022 as ls join revenue_2023 cs
on ls.branch=cs.branch
where ls.revenue_2022>cs.revenue_2023
order by decrease_ratio desc
limit 5;
