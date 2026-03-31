create or alter procedure sp_ImportingData
as
begin 

--STAGING TABLES

--Customers
create table #_staging_Customers
(
   customer_id int
  ,first_name nvarchar(255)
  ,last_name nvarchar(255)
  ,phone nvarchar(255)
  ,email nvarchar(255)
  ,street nvarchar(255)
  ,city nvarchar(255)
  ,state nvarchar(255)
  ,zip_code int
);


--Stores
create table #_staging_Stores
(
   store_id int
  ,store_name nvarchar(255)
  ,phone nvarchar(255)
  ,email nvarchar(255)
  ,street nvarchar(255)
  ,city nvarchar(255)
  ,state nvarchar(255)
  ,zip_code int
);


--Categories
create table #_staging_Categories
(
  category_id int,
  category_name nvarchar(255)
);


--Brands
create table #_staging_Brands
(
   brand_id int
  ,brand_name nvarchar(255)
);


--Staffs
create table #_staging_Staffs (
    staff_id int,
    first_name nvarchar(255),
	last_name nvarchar(255),
    email nvarchar(255),
	phone nvarchar(255),
	active nvarchar(255),
    store_id int,
    manager_id nvarchar(255)
);

--Products
create table #_staging_Products (
    product_id int,
    product_name nvarchar(255),
    brand_id int,
    category_id int,
    model_year int,
    list_price nvarchar(255)
);

--Orders
create table #_staging_Orders (
    order_id int,
    customer_id int,
    order_status int,
    order_date nvarchar(255),
    required_date nvarchar(255),
    shipped_date nvarchar(255),
    store_id int,
    staff_id int
);

--Stocks
create table #_staging_Stocks (
    store_id int,
    product_id int,
    quantity int,
);

--Order_items
create table #_staging_Order_items (
    order_id int,
    item_id int,
    product_id int,
    quantity int,
    list_price nvarchar(255),
    discount nvarchar(255)
);

-- BULK INSERT INTO STAGING TABLES
   
BULK INSERT #_staging_Brands
FROM 'D:\Data\brands.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT #_staging_Categories
FROM 'D:\Data\categories.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT #_staging_Customers
FROM 'D:\Data\customers.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT #_staging_Stores
FROM 'D:\Data\stores.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT #_staging_Products
FROM 'D:\Data\products.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT #_staging_Staffs
FROM 'D:\Data\staffs.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT #_staging_Orders
FROM 'D:\Data\orders.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT #_staging_Stocks
FROM 'D:\Data\stocks.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);


BULK INSERT #_staging_Order_items
FROM 'D:\Data\order_items.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

	UPDATE #_staging_Customers
	set phone = null
	where phone = 'null'

	UPDATE #_staging_Orders
	set shipped_date = null
	where shipped_date = 'null'
	
	UPDATE #_staging_Staffs
	set manager_id = null
	where manager_id = 'null'


-- MERGE: Move data from staging to main tables

MERGE Sales.Stores AS target
USING #_staging_Stores AS source
ON target.store_id = source.store_id
WHEN MATCHED THEN
	UPDATE SET
		store_name = source.store_name,
		phone = source.phone,
		email = source.email,
		street = source.street,
		city = source.city,
		state = source.state,
		zip_code = source.zip_code
WHEN NOT MATCHED THEN
	INSERT (store_id, store_name, phone, email, street, city, state, zip_code)
	VALUES (source.store_id, source.store_name, source.phone, source.email, source.street, source.city, source.state, source.zip_code);


-- 2. CATEGORIES
MERGE Production.Categories AS target
USING #_staging_Categories AS source
ON target.category_id = source.category_id
WHEN MATCHED THEN
	UPDATE SET category_name = source.category_name
WHEN NOT MATCHED THEN
	INSERT (category_id, category_name)
	VALUES (source.category_id, source.category_name);


-- 3. BRANDS
MERGE Production.Brands AS target
USING #_staging_Brands AS source
ON target.brand_id = source.brand_id
WHEN MATCHED THEN
	UPDATE SET brand_name = source.brand_name
WHEN NOT MATCHED THEN
	INSERT (brand_id, brand_name)
	VALUES (source.brand_id, source.brand_name);


-- 4. PRODUCTS
MERGE Production.Products AS target
USING (
	SELECT product_id, product_name, brand_id, category_id, model_year,
		CAST(list_price AS DECIMAL(10,2)) AS list_price
	FROM #_staging_Products
) AS source
ON target.product_id = source.product_id
WHEN MATCHED THEN
	UPDATE SET
		product_name = source.product_name,
		brand_id = source.brand_id,
		category_id = source.category_id,
		model_year = source.model_year,
		list_price = source.list_price
WHEN NOT MATCHED THEN
	INSERT (product_id, product_name, brand_id, category_id, model_year, list_price)
	VALUES (source.product_id, source.product_name, source.brand_id, source.category_id, source.model_year, source.list_price);


-- 5. CUSTOMERS
MERGE Sales.Customers AS target
USING #_staging_Customers AS source
ON target.customer_id = source.customer_id
WHEN MATCHED THEN
	UPDATE SET
		first_name = source.first_name,
		last_name = source.last_name,
		phone = source.phone,
		email = source.email,
		street = source.street,
		city = source.city,
		state = source.state,
		zip_code = source.zip_code
WHEN NOT MATCHED THEN
	INSERT (customer_id, first_name, last_name, phone, email, street, city, state, zip_code)
	VALUES (source.customer_id, source.first_name, source.last_name, source.phone, source.email, source.street, source.city, source.state, source.zip_code);


-- 6. STAFFS
MERGE Sales.Staffs AS target
USING (
	SELECT staff_id, first_name, last_name, email, phone, active, store_id,
		CAST(CASE WHEN manager_id = 'NULL' then NULL else manager_id end AS INT) AS manager_id
	FROM #_staging_Staffs
) AS source
ON target.staff_id = source.staff_id
WHEN MATCHED THEN
	UPDATE SET
		first_name = source.first_name,
		last_name = source.last_name,
		email = source.email,
		phone = source.phone,
		active = source.active,
		store_id = source.store_id,
		manager_id = source.manager_id
WHEN NOT MATCHED THEN
	INSERT (staff_id, first_name, last_name, email, phone, active, store_id, manager_id)
	VALUES (source.staff_id, source.first_name, source.last_name, source.email, source.phone, source.active, source.store_id, source.manager_id);


-- 7. ORDERS
MERGE Sales.Orders AS target
USING (
	SELECT order_id, customer_id, order_status,
		CAST(CASE WHEN order_date = 'NULL' THEN NULL ELSE order_date END AS DATETIME) AS order_date,
		CAST(CASE WHEN required_date = 'NULL' THEN NULL ELSE required_date END AS DATETIME) AS required_date,
		CAST(CASE WHEN shipped_date = 'NULL' THEN NULL ELSE shipped_date END AS DATETIME) AS shipped_date,
		store_id, staff_id
	FROM #_staging_Orders
) AS source
ON target.order_id = source.order_id
WHEN MATCHED THEN
	UPDATE SET
		customer_id = source.customer_id,
		order_status = source.order_status,
		order_date = source.order_date,
		required_date = source.required_date,
		shipped_date = source.shipped_date,
		store_id = source.store_id,
		staff_id = source.staff_id
WHEN NOT MATCHED THEN
	INSERT (order_id, customer_id, order_status, order_date, required_date, shipped_date, store_id, staff_id)
	VALUES (source.order_id, source.customer_id, source.order_status, source.order_date, source.required_date, source.shipped_date, source.store_id, source.staff_id);


-- 8. ORDER ITEMS
MERGE Sales.Order_items AS target
USING (
	SELECT order_id, item_id, product_id, quantity,
		CAST(list_price AS DECIMAL(10,2)) AS list_price,
		CAST(discount AS DECIMAL(4,2)) AS discount
	FROM #_staging_Order_items
) AS source
ON target.order_id = source.order_id AND target.item_id = source.item_id
WHEN MATCHED THEN
	UPDATE SET
		product_id = source.product_id,
		quantity = source.quantity,
		list_price = source.list_price,
		discount = source.discount
WHEN NOT MATCHED THEN
	INSERT (order_id, item_id, product_id, quantity, list_price, discount)
	VALUES (source.order_id, source.item_id, source.product_id, source.quantity, source.list_price, source.discount);


-- 9. STOCKS
MERGE Production.Stocks AS target
USING #_staging_Stocks AS source
ON target.store_id = source.store_id AND target.product_id = source.product_id
WHEN MATCHED THEN
	UPDATE SET quantity = source.quantity
WHEN NOT MATCHED THEN
	INSERT (store_id, product_id, quantity)
	VALUES (source.store_id, source.product_id, source.quantity);

end


exec sp_ImportingData

SELECT * FROM Production.Brands
select * from Production.Stocks
Select * from Sales.Order_items
select * from Sales.Orders
select * from Sales.Staffs
select * from Sales.Customers

