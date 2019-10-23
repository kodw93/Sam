-- Week 5 

-- Subqueries and Views
-- 1. What is the lifetime average amount spent in USD for the top 10 total spending accounts?
select round(avg(total_amt),2)
from(
	select a.name, sum(total_amt_usd) as total_amt
	from accounts a
	join orders o
	on a.id = o.account_id
	group by a.name
	order by total_amt desc
	limit 10) as table1

-- Method #2: using "View"
create view table2 as 
	select a.name, sum(total_amt_usd) as total_amt
	from accounts a
	join orders o
	on a.id = o.account_id
	group by a.name
	order by total_amt desc
	limit 10

select round(avg(total_amt),2)
from table2

-- or Method #3: using a "with" statement
-- unlike view, "with" does NOT store in the variable; therefore, have to run the entire script together
with table3 as (
	select a.name, sum(total_amt_usd) as total_amt
	from accounts a
	join orders o
	on a.id = o.account_id
	group by a.name
	order by total_amt desc
	limit 10)
select round(avg(total_amt),2)
from table3


-- 2. For the customer/account that spent the most (in total over their lifetime as a customer) total_amt_usd, 
-- how many web_events did they have for each channel?
select customer, w.channel, count(w.channel)
from (select a.id, a.name as customer, sum(total_amt_usd) as total_amt
	from accounts a
	join orders o
	on a.id=o.account_id
	group by customer, a.id
	order by total_amt desc
	limit 1) as tbl1
join web_events w
on tbl1.id = w.account_id
group by w.channel, customer;

-- or using "WITH"
with tbl2 as (select a.id, a.name as customer, sum(total_amt_usd) as total_amt
	from accounts a
	join orders o
	on a.id=o.account_id
	group by customer, a.id
	order by total_amt desc
	limit 1)
select customer, w.channel, count(w.channel)
from tbl2
join web_events w
on tbl2.id = w.account_id
group by customer, w.channel


-- 3.Which channel was the most frequently used by different accounts?
select name, max(total_count)
from (
	select a.name, w.channel, count(*) as total_count
	from accounts a
	join web_events w
	on a.id = w.account_id
	group by a.name, w.channel
	order by a.name, w.channel) as tbl3
group by name
-- but this does not show the channel

create view table_1 as  
	select a.name, w.channel, count(*) as total_count
	from accounts a
	join web_events w
	on a.id = w.account_id
	group by a.name, w.channel
	order by a.name, w.channel
	
create view table_2 as 
	select name, max(total_count)
	from (
		select a.name, w.channel, count(*) as total_count
		from accounts a
		join web_events w
		on a.id = w.account_id
		group by a.name, w.channel
		order by a.name, w.channel) as tbl_3
	group by name
	
select table_2.name, table_1.channel, max(total_count) max_total_count
from table_1
join table_2
on table_1.name = table_2.name
where table_2.max = table_1.total_count
group by table_2.name, table_1.channel
order by table_2.name

-- or 
with tbl1 as (
	select a.name, w.channel, count(*) total_count
	from accounts a
	join web_events w
	on a.id = w.account_id
	group by a.name, w.channel
	order by a.name, w.channel),
tbl2 as (
	select name, max(total_count) max_total_count
	from tbl1
	group by name)
select tbl1.name, tbl1.channel, tbl2.max_total_count
from tbl1
join tbl2
on tbl1.name = tbl2.name
where tbl1.total_count = tbl2.max_total_count
order by tbl1.name



-- 4. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
with table1 as (select r.name region, s.name sales_rep, sum(total_amt_usd) as total_amt
	from sales_reps s
	join region r
	on s.region_id = r.id
	join accounts a
	on s.id = a.sales_rep_id
	join orders o
	on a.id = o. account_id
	group by s.name, r.name),

table2 as (select region, max(total_amt) as max_total
	from table1
	group by region)

select table2.region, table1.sales_rep,table2.max_total
from table1
join table2 
on table1.region = table2.region
where table1.total_amt = table2.max_total
order by table2.region


