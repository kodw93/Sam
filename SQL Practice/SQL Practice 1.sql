-- Lab 4 09/16/2019

-- 1. Find the total sales in usd for each account. You should include two columns: the total sales for each company’s orders in usd 
-- and the company name.
select a.name as "Company", sum(o.total_amt_usd) as "Total Sales"
from orders o
join accounts a
on o.account_id = a.id
group by a.name
order by "Total Sales" desc;

-- 2.Find the total number of times each type of channel from the web_events was used. Your final table should have two columns:
-- the channel and the number of times the channel was used. 
select channel, count(channel)
from web_events
group by channel
order by count(channel) desc;

-- 3. What was the largest order placed by each account in terms of total usd. Provide only two columns:
-- the account name and the total usd. Order the data by dollar amount.
select a.name, max(o.total_amt_usd) as "Largest Order"
from accounts a
join orders o on a.id = o.account_id
group by a.name
order by "Largest Order" desc;

-- 4. Find the number of sales reps in each region. Your final table should have two columns the region and the number of sales_reps. 
-- Order from fewest reps to most reps.
select r.name, count(*) as "Number of Sales_Reps"
from region r
join sales_reps s
on r.id = s.region_id
group by r.name
order by 2 desc; -- order by the 2nd column 

--5. For each account, determine the average amount of each type of paper they purchased across their orders. 
-- Your result should have four columns - one for the account name and one for the average spent on each of the paper types.
select a.name, round(avg(o.standard_amt_usd),2) as "Average Standard Paper #", 
	round(avg(o.poster_amt_usd),2) as "Average Poster Paper #", 
	round(avg(o.gloss_amt_usd),2) as "Average Gloss Paper #"
from accounts a
join orders o 
on a.id = o.account_id
group by a.name

-- 6. Determine the number of times a particular channel was used in the web_events table for each sales rep.
-- Your final table should have three columns - the name of the sales rep, the channel, and the number of occurrences. 
-- Order your table with the highest number of occurrences first.
select s.name, w.channel, count(*) as "Number of Occurrences"
from sales_reps s
join accounts a on s.id = a.sales_rep_id
join web_events w on a.id = w.account_id
group by s.name, w.channel
-- order by s.name, w.channel
Order by "Number of Occurrences" desc

-- 7. How many of the sales reps have more than 5 accounts that they manage?
select count(*)
from (select s.id, count(*) as num_of_accounts
	  from sales_reps s
	  join accounts a on s.id = a.sales_rep_id
	  group by s.id 
	  having count(a.id) > 5) table_1 -- always need an alias when performing subquery
	  
-- 8.  How many accounts have more than 20 orders?
select count(*)
from (select a.id, count(o.id)
	  from accounts a
	  join orders o on a.id = o.account_id
	  group by a.id
	  having count(o.id) > 20) table_1
	  
-- we don't even have to join tables here	  
select count(*)
from (select account_id, count(*) as "Total Orders"
	  from orders 
	  group by account_id
	  having count(*) > 20) table_1
	  
-- 9. Which account has the most orders?
select a.name, count(o.id)
from accounts a
join orders o on a.id=o.account_id
group by a.name
order by 2 desc
limit 1

-- 10. How many accounts spent more than $30,000 total with Parch and Posey throughout the years?
select count (*)
from (select a.name, sum(o.total_amt_usd)
	  from accounts a
	  join orders o on a.id=o.account_id
	  group by a.name
	  having sum(o.total_amt_usd) > 30000) table_1

-- 11. Which account has spent the most with us?
select a.name, sum(o.total_amt_usd) as "Total"
from accounts a
join orders o on a.id = o.account_id
group by a.name
order by "Total" desc
limit 1

-- 12. Which account used facebook most as a channel?
select a.name, w.channel, count(*) as "Count"
from accounts a
join web_events w on a.id = w.account_id
where w.channel = 'facebook'
group by a.name, w.channel
order by "Count" desc
limit 1

-- 13. Which accounts used facebook as a channel to contact customers more than 6 times?
select a.name, w.channel, count(*) as "Count"
from accounts a
join web_events w on a.id = w.account_id
where w.channel = 'facebook'
group by a.name, w.channel 
having count(*) > 6 
order by "Count" desc

select a.name, w.channel, count(*) as "Count"
from accounts a
join web_events w on a.id = w.account_id
group by a.name, w.channel 
having w.channel = 'facebook' and count(*) > 6 
order by "Count" desc

-- 14. Which channel was the most frequently used by different accounts?
select channel, count(*)
from (select a.name, w.channel, count(*) as "Count"
from accounts a
join web_events w on a.id = w.account_id
group by a.name, w.channel
order by "Count" desc) table_1
group by table_1.channel

-- obviously very different from this
select w.channel, count (*)
from accounts a
join web_events w on a.id = w.account_id
group by w.channel


-- 15. Find the sales ($) for all orders in each year, ordered from largest to smallest. 
-- Do you notice any trends in the yearly sales totals?
select date_part('year', occurred_at) order_year, sum(total_amt_usd) total_spent
from orders
group by order_year
order by 1

-- 16. Which month did Parch & Posey have the largest sales ($) in 2016?
select date_part('year', occurred_at) as order_year, date_part('month',occurred_at) order_month, sum(total_amt_usd) total_sales
from orders
where date_part('year', occurred_at) = 2016
group by order_year, order_month
order by 3 desc
limit 1

select date_part('month',occurred_at) order_month, sum(total_amt_usd) total_sales
from orders
where date_part('year', occurred_at) = 2016
group by order_month
order by 2 desc
limit 1

-- 17. In which year and month did Walmart spend($) the most on gloss paper?
select date_part('year',occurred_at) as "Year", date_part('month',occurred_at) as "Month", sum(gloss_amt_usd) as "Gloss Sum"
from orders
group by "Year", "Month" 
order by 3 desc
limit 1;

select date_trunc('month', o.occurred_at) order_date, sum(o.gloss_amt_usd) total_spent
from orders o
join accounts a
on o.account_id = a.id
where a.name = 'Walmart'
group by 1
order by 2 desc
limit 1


-- 18. We would like to understand 3 different branches of customers based on the amount associated with
-- their purchases. The top branch includes anyone with a Lifetime Value (total sales of all orders) greater
-- than 200,000 usd. The second branch is between 200,000 and 100,000 usd. The lowest branch is anyone
-- under 100,000 usd. Provide a table that includes the level associated with each account. You should
-- provide the account name, the total sales of all orders for the customer, and the level. Order with the
-- top spending customers listed first.
select a.name, sum(o.total_amt_usd), 
	case when sum(o.total_amt_usd) > 200000 then 'Top'
	when sum(o.total_amt_usd) < 100000 then 'Low'
	else 'Medium'
	End as "Level"
from orders o
join accounts a
on o.account_id = a.id
group by a.name

select a.name, sum(o.total_amt_usd), 
	case when sum(o.total_amt_usd) > 200000 then 'Top'
	when sum(o.total_amt_usd) > 100000 then 'Medium'
	else 'Low'
	End as "Level"
from orders o
join accounts a
on o.account_id = a.id
group by a.name



-- 19. Restrict the results of the preivous question to the orders occurred only in 2016 and 2017.
select a.name, sum(o.total_amt_usd), 
	case when sum(o.total_amt_usd) > 200000 then 'Top'
	when sum(o.total_amt_usd) > 100000 then 'Medium'
	else 'Low'
	End as "Level"
from orders o
join accounts a
on o.account_id = a.id
where date_part('year', o.occurred_at) in (2016,2017)
group by a.name


-- 20. We would like to identify top performing sales reps, which are sales reps associated
-- with more than 200 orders. Create a table with the sales rep name, the total number of orders, and a
-- column with top or not depending on if they have more than 200 orders. Place the top sales people
-- first in your final table.
select s.name, count(o.id), 
	case when count(o.id) > 200 then 'Top'
	else 'Not Top' 
	end as "TOP?"
from sales_reps s
join accounts a
on s.id = a.sales_rep_id
join orders o
on a.id = o.account_id
group by s.name
order by 2 desc

-- 21. The previous question didn’t account for the middle, nor the dollar amount associated with the sales.
-- Management decides they want to see these characteristics represented as well. We would like to identify
-- top performing sales reps, which are sales reps associated with more than 200 orders or more than
-- 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales.
-- Create a table with the sales rep name, the total number of orders, total sales across all orders, and a
-- column with top, middle, or low depending on this criteria. Place the top sales people based on dollar amount 
-- of sales first in your final table. 
select s.name, count(o.id), sum(total_amt_usd) total_spent,
	case when count(o.id) > 200 or sum(total_amt_usd) > 750000 then 'Top'
	when count(o.id) > 150 or sum(total_amt_usd) > 500000 then 'Middle'
	else 'Low' 
	end as "Level"
from sales_reps s
join accounts a
on s.id = a.sales_rep_id
join orders o
on a.id = o.account_id
group by s.name
order by 3 desc



