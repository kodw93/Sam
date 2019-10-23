-- Week 6: Data Cleadning and Window Functions in SQL

-- Data Cleaning
-- Left and Right
--1. In the accounts table, there is a column holding the website for each company. The last three digits specify what type of 
-- web address they are using. Pull these extensions and provide how many of each website type exist in the accounts table.
select right(website, 3) as ext, count(*)
from accounts
group by ext
order by 2 desc;

-- 2. There is much debate about how much the name (or even the first letter of a company name) matters.
-- Use the accounts table to pull the first letter of each company name to see the distribution of company names 
-- that begin with each letter (or number).
select  left(name,1) as firstletter, count(*)
from accounts
group by firstletter
order by firstletter;

-- if want to combine the lower case and upper case,
select  upper(left(name,1)) as firstletter, count(*)
from accounts
group by firstletter
order by firstletter;

--3. What is the number of company names that start with a vowel and consonant letters?
	-- we have to create a new variable (lette_type) to state if a name starts with vowel or consonant
with t1 as (
select left(name,1) as letter,
	case when lower(left(name,1)) in ('a','e','i','u','o') then 'vowel' else 'consonant'
	end as letter_type
from accounts)
select letter_type, count(*)
from t1
group by letter_type


-- Position
-- 4. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
select primary_poc, position(' ' in primary_poc), length(primary_poc),
	left(primary_poc, position(' ' in primary_poc) - 1) as FirstName,
	right(primary_poc, length(primary_poc) - position(' ' in primary_poc)) as LastName
from accounts


-- Concat
-- 5&6. Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the 
-- first name of the primary_poc last name primary_poc @ company name.com. (e.g. tamara.tuma@walmart.com)

select lower(concat(left(primary_poc, position(' ' in primary_poc) - 1), '.' ,
			  right(primary_poc, length(primary_poc) - position(' ' in primary_poc)),
			  '@', replace(name, ' ',''),'.','com'))
from accounts


--7. We would also like to create an initial password, which they will change after their first log in. The
-- password will be a combination of:
-- • the first letter of the primary_poc’s first name (lowercase),
-- • the last letter of their first name (lowercase),
-- • the first letter of their last name (uppercase),
-- • the last letter of their last name (uppercase),
-- • the number of letters in their first name,
-- • the number of letters in their last name, and
-- • the name of the company they are working with, no spaces
-- • the forth and fifth digit of their sales rep id
select concat(lower(left(primary_poc,1)),
lower(right(left(primary_poc, position(' ' in primary_poc) - 1),1)),
upper(left(right(primary_poc, length(primary_poc) - position(' ' in primary_poc)),1)),
upper(right(primary_poc,1)),
length(left(primary_poc, position(' ' in primary_poc) - 1)),
length(right(primary_poc, length(primary_poc) - position(' ' in primary_poc))),
replace(name, ' ',''),
substr(sales_rep_id::text, 4,2))
from accounts


with t1 as (
select primary_poc, replace(name,' ','') as company, sales_rep_id,
	lower(left(primary_poc, position(' ' in primary_poc)-1)) as firstname,
	lower(right(primary_poc, length(primary_poc) - position(' ' in primary_poc))) as lastname
	from accounts)
select primary_poc, concat(left(firstname, 1),
						  right(firstname,1),
						  upper(left(lastname,1)),
						   upper(right(lastname,1)),
						   length(firstname),
						   length(lastname),
						   company,
						   substr(sales_rep_id::text, 4,2))
from t1


-- Windows Function
-- 8. For the orders table, create a new column which shows the total number of transactions for all accounts.
select *, sum(total_amt_usd) over() as overall_total
from orders;

-- 9. Update the previous query to create two new column: (1) over_all_total_by_account_id, and 
-- (2) overall_count_by_account_id (without using Group By).
select account_id, total_amt_usd,
	sum(total_amt_usd) over(partition by account_id) as overall_total_by_accountid,
	count(account_id) over (partition by account_id) as overall_count_by_accountid
from orders;

-- 10. Create a running total of standard_amt_usd (in the orders table) over order time.
select occurred_at, standard_amt_usd, 
	sum(standard_amt_usd) over(order by occurred_at) as running_total
from orders

-- 11. Create a running total of standard_amt_usd (in the orders table) over order time for each month.
select occurred_at, standard_amt_usd, date_trunc('month', occurred_at),
	sum(standard_amt_usd) over(partition by date_trunc('month', occurred_at) order by occurred_at) as running_total_month
from orders
								-- this running total resets in the beginning of each month! 


-- 12. Create a running total of standard_qty (in the orders table) over order time for each year.
select standard_qty, occurred_at, date_part('year', occurred_at),
	sum(standard_qty) over (partition by date_part('year', occurred_at) order by occurred_at) as running_total_year
from orders



-- Ranking data: ROW_NUMBER() and RANK(), DENSE_RANK()
-- 13. For account with id 1001, use the row_number(), rank() and dense_rank() to rank the transactions 
-- by the number of standard paper purchased.
select standard_qty,
	row_number() over(order by standard_qty),
	rank() over (order by standard_qty),
	dense_rank() over (order by standard_qty)
from orders
where account_id = 1001


-- 14. For each account, use the row_number(), rank() and dense_rank() to rank the transactions 
-- by the number of standard paper purchased.
select account_id, standard_qty,
	row_number() over(partition by account_id order by standard_qty),
	rank() over (partition by account_id order by standard_qty),
	dense_rank() over (partition by account_id order by standard_qty)
from orders


-- 15. Select the id, account_id, and standard_qty variable from the orders table, then create a column called 
-- dense_rank that ranks this standard_qty amount of paper for each account. 
-- In addition, create a sum_std_qty which gives you the running total for account. Repeat the last task to get the avg, min, and max.
select id, account_id, standard_qty,
	dense_rank() over (partition by account_id order by standard_qty) as dense_rank,
	sum(standard_qty) over (partition by account_id order by standard_qty) as sum_std_qty,
	round(avg(standard_qty) over (partition by account_id order by standard_qty),2) as avg_std_qty,
	min(standard_qty) over (partition by account_id order by standard_qty) as min_std_qty,
	max(standard_qty) over (partition by account_id order by standard_qty) as max_std_qty
from orders

-- 16. Give an allias for the window function in the previous question, and call it account_window.
select id, account_id, standard_qty,
	dense_rank() over account_window as dense_rank,
	sum(standard_qty) over account_window as sum_std_qty,
	round(avg(standard_qty) over account_window ,2) as avg_std_qty,
	min(standard_qty) over account_window as min_std_qty,
	max(standard_qty) over account_window as max_std_qty
from orders
window account_window as (partition by account_id order by standard_qty)


-- NTILES
-- 17. Use the NTILE functionality to divide the accounts into 4 levels in terms of the amount of standard_qty for their orders. 
-- Your resulting table should have the account_id, the occurred_at time for each order, the total amount of standard_qty paper purchased, 
-- and one of four levels in a standard_quartile column.
select account_id, occurred_at, standard_qty,
	ntile(4) over (partition by account_id order by standard_qty) as standard_qty_quartile
from orders

-- 18. Use the NTILE functionality to divide the accounts into two levels in terms of the
-- amount of gloss_qty for their orders. Your resulting table should have the account_id, the occurred_at
-- time for each order, the total amount of gloss_qty paper purchased, and one of two levels in a gloss_half column.
select account_id, occurred_at, gloss_qty, 
	ntile(2) over (partition by account_id order by gloss_qty) as gloss_qty_quartile
from orders


