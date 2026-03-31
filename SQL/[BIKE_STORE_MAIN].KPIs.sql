--Business KPIs
--Total Revenue	Company-wide performance
--Average Order Value (AOV)	Customer spending behavior
--Inventory Turnover	Efficiency of stock flow
--Product Return Rate	(if applicable) – Quality issues?
--Revenue by Store	Identifies top/weak branches
--Gross Profit by Category	High/low margin areas
--Sales by Brand	Vendor effectiveness
--Staff Revenue Contribution	Productivity tracking

use [BIKE_STORE_MAIN]

--Total Revenue	Company-wide performance
select
cast(sum(quantity * list_price * (1- discount)) as decimal(10,2)) as Revenue
from [Sales].[Order_items]

--Average Order Value (AOV)	Customer spending behavior
select 
cast(sum(quantity * list_price * (1- discount)) as decimal(10,2)) /
count(distinct order_id) as AOV
from [Sales].[Order_items]

--Inventory Turnover	Efficiency of stock flow
select * from [Sales].[Order_items]
select * from [Production].[Stocks]

select  
cast(
(select sum(quantity) from Sales.Order_items) * 1.0 /
(select sum(quantity) from Production.Stocks) as decimal(10,2)) as KPI_Value;

--Product Return Rate	(if applicable) – Quality issues?
select
cast(
(SELECT count(*) from Sales.Orders
where order_status = 3) * 100.0 / 
(select count(*) from Sales.Orders) as decimal(10,2)) as KPI_Value_Percentage;

--Revenue by Store	Identifies top/weak branches
select
s.store_name,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as Total_Revenue,
count(distinct o.order_id) as Total_Orders
from [Sales].[Stores]as s
join [Sales].[Orders] as o 
on s.store_id = o.store_id
join [Sales].[Order_items] as oi
on o.order_id = oi.order_id
group by s.store_name
order by Total_Revenue desc

--Gross Profit by Category	High/low margin areas
select 
c.category_name,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as Gross_Revenue,
count(distinct oi.order_id) as Sales_Count
from [Production].[Categories] as c
join [Production].[Products] as p 
on c.category_id = p.category_id
join [Sales].[Order_items] as oi
on p.product_id = oi.product_id
group by c.category_name
order by Gross_Revenue desc

--Sales by Brand	Vendor effectiveness
DECLARE @TotalRev decimal(18,2);
select @TotalRev = sum(quantity * list_price * (1 - discount)) from Sales.Order_items;

select
b.brand_name,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(18,2)) as Brand_Revenue,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) * 100.0 / @TotalRev as decimal(5,2)) as Revenue_Share_Percent
from [Production].[Brands] as b
join [Production].[Products] as p 
on b.brand_id = p.brand_id
join [Sales].[Order_items] as oi
on p.product_id = oi.product_id
group by b.brand_name
order by Brand_Revenue desc

--Staff Revenue Contribution	Productivity tracking
select 
s.first_name + ' ' + s.last_name as Full_Name,
count(distinct o.order_id) as Orders_Processed,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(18,2)) as Total_Revenue_Generated
from [Sales].[Staffs] as s
join [Sales].[Orders] o on s.staff_id = o.staff_id
join [Sales].[Order_items] as oi on o.order_id = oi.order_id
group  by s.first_name, s.last_name
order by Total_Revenue_Generated desc


