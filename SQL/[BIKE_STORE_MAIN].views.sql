--•	vw_StoreSalesSummary: Revenue, #Orders, AOV per store
--•	vw_TopSellingProducts: Rank products by total sales
--•	vw_InventoryStatus: Items running low on stock
--•	vw_StaffPerformance: Orders and revenue handled per staff
--•	vw_RegionalTrends: Revenue by city or region
--•	vw_SalesByCategory: Sales volume and margin by product category

use [BIKE_STORE_MAIN]

--vw_StoreSalesSummary
select * from [Sales].[Stores]
select * from [Sales].[Orders]
select * from [Sales].[Order_items]

create view vw_StoreSalesSummary
as 
select 
s.store_name,
sum(oi.quantity * oi.list_price * (1- oi.discount)) as Revenue,
count(distinct o.order_id) as Orders,
sum(oi.quantity * oi.list_price * (1- oi.discount)) / 
count(distinct o.order_id) as AOV
from [Sales].[Stores] as s
join [Sales].[Orders] as o on s.store_id = o.store_id
join [Sales].[Order_items] as oi on o.order_id = oi.order_id
group by s.store_name

select * from vw_StoreSalesSummary

--vw_TopSellingProducts
select * from [Production].[Products]
select * from [Sales].[Order_items]

create view vw_TopSellingProducts
as 
select
p.product_name,
sum(oi.quantity) AS Total_quantity,
DENSE_RANK() over (order by sum(oi.quantity) desc) as Sales_Rank
from [Production].[Products] as p
join [Sales].[Order_items] as oi on p.product_id = oi.product_id
group by p.product_name

select * from vw_TopSellingProducts

--vw_InventoryStatus
select * from [Production].[Products]
select * from [Production].[Stocks]
select * from [Production].[Brands]

create view vw_InventoryStatus
as
select 
p.product_name, b.brand_name,
sum(s.quantity) as Total_quantitiy,
case
when sum(s.quantity) = 0 then 'Out of Stock'
when sum(s.quantity) < 10 then 'Low Stock'
else 'In Stock'
end as Inventory_Level
from [Production].[Products] as p
join [Production].[Stocks] as s
on p.product_id = s.product_id
join [Production].[Brands] as b 
on p.brand_id = b.brand_id
group by p.product_name, b.brand_name

select * from vw_InventoryStatus

--vw_StaffPerformance
select * from [Sales].[Staffs]
select * from [Sales].[Orders]
select * from [Sales].[Order_items]

create view vw_StaffPerformance
as
select
s.first_name + ' ' + s.last_name as Fullname,
count(distinct o.order_id) AS Total_Orders,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as Total_Revenue
from [Sales].[Staffs] as s 
join [Sales].[Orders] as o 
on s.staff_id = o.staff_id
join [Sales].[Order_items] as oi
on o.order_id = oi.order_id
group by s.first_name, s.last_name

select * from vw_StaffPerformance
order by Total_Orders desc

--vw_RegionalTrends
select * from [Sales].[Customers]
select * from [Sales].[Orders]
select * from [Sales].[Order_items]

create view vw_RegionalTrends
as 
select 
c.city,
c.state,
count(distinct o.order_id) as Total_Orders,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as Revenue
from [Sales].[Customers] as c 
join [Sales].[Orders] as o 
on c.customer_id = o.customer_id
join [Sales].[Order_items] as oi 
on o.order_id = oi.order_id
group by c.city, c.state

select * from vw_RegionalTrends
order by Revenue desc

--vw_SalesByCategory
select * from [Production].[Categories]
select * from [Production].[Products]
select * from [Sales].[Order_items]

create view vw_SalesByCategory
as 
select 
c.category_name,
sum(oi.quantity) as Total_Units_Sold,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as Total_Revenue,
cast(avg(oi.list_price * (1 - oi.discount)) as decimal(10,2)) AS Average_UnitPrice
from [Production].[Categories] as c
join [Production].[Products] as p 
on c.category_id = p.category_id
join [Sales].[Order_items] as oi
on p.product_id = oi.product_id
GROUP BY c.category_name

SELECT * FROM vw_SalesByCategory
ORDER BY Total_Revenue DESC