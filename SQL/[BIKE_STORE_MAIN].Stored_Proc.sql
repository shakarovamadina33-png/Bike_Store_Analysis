--•	sp_CalculateStoreKPI: Input store ID, return full KPI breakdown
--•	sp_GenerateRestockList: Output low-stock items per store
--•	sp_CompareSalesYearOverYear: Compare sales between two years
--•	sp_GetCustomerProfile: Returns total spend, orders, and most bought items

use [BIKE_STORE_MAIN]

--sp_CalculateStoreKPI
create procedure sp_CalculateStoreKPI
	@StoreId int
as
begin
select 
s.store_name,
count(distinct o.order_id) as Total_Orders,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as Total_Revenue,
count(distinct o.customer_id) as Unique_Customers,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) / count(distinct o.order_id) as decimal(10,2)) as AOV
from Sales.Stores s
join Sales.Orders o ON s.store_id = o.store_id
join Sales.Order_items oi ON o.order_id = oi.order_id
where s.store_id = @StoreId
group by s.store_name;
end;

EXEC sp_CalculateStoreKPI @StoreId = 1;

--sp_GenerateRestockList
create procedure sp_GenerateRestockList
    @MinStockLevel int
as
begin
select 
st.store_name,
p.product_name,
s.quantity as Current_Stock
from Production.Stocks as s
join Production.Products as p on s.product_id = p.product_id
join Sales.Stores as st on s.store_id = st.store_id
where s.quantity < @MinStockLevel
order by st.store_name, s.quantity asc;
end;

EXEC sp_GenerateRestockList @MinStockLevel = 5;

--sp_CompareSalesYearOverYear
create procedure sp_CompareSalesYearOverYear
    @Year1 int,
    @Year2 int
as
begin
select 
year(o.order_date) as Sale_Year,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as Yearly_Revenue
from Sales.Orders o
join Sales.Order_items oi ON o.order_id = oi.order_id
where year(o.order_date) IN (@Year1, @Year2)
group by year(o.order_date)
order by Sale_Year;
end;

EXEC sp_CompareSalesYearOverYear @Year1 = 2017, @Year2 = 2018;

--sp_GetCustomerProfile 
create procedure sp_GetCustomerProfile
    @CustomerId int
as
begin
select 
c.first_name + ' ' + c.last_name as Customer_Name,
count(distinct o.order_id) as Total_Orders,
cast(sum(oi.quantity * oi.list_price * (1 - oi.discount)) as decimal(10,2)) as Total_Spent,
(
	select TOP 1 p.product_name 
	from Sales.Order_items oi2
	join Production.Products p on oi2.product_id = p.product_id
	join Sales.Orders o2 on oi2.order_id = o2.order_id
	where o2.customer_id = @CustomerId
	group by p.product_name
	order by sum(oi2.quantity) desc) as MostBoughtItem
from Sales.Customers c
join Sales.Orders o on c.customer_id = o.customer_id
join Sales.Order_items oi on o.order_id = oi.order_id
where c.customer_id = @CustomerId
group by c.first_name, c.last_name;
end;

EXEC sp_GetCustomerProfile @CustomerId = 1;