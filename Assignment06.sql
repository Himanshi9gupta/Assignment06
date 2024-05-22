--*************************************************************************--
-- Title: Assignment06
-- Author: HimanshiGupta
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2024-05-21,HimanshiGupta,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_HimanshiGupta')
	 Begin 
	  Alter Database [Assignment06DB_HimanshiGupta] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_HimanshiGupta;
	 End
	Create Database Assignment06DB_HimanshiGupta;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_HimanshiGupta;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

CREATE VIEW vCategories AS
SELECT CategoryID, CategoryName
FROM Categories;     

SELECT * FROM vCategories;

CREATE VIEW vProducts AS
SELECT p.ProductID, p.ProductName, p.CategoryID, p.UnitPrice
FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID;   

CREATE VIEW vInventories AS
SELECT p.ProductID, i.EmployeeID, i.[Count], i.InventoryDate, i.InventoryID
FROM Inventories i
JOIN Products p ON p.ProductID = i.ProductID;   

CREATE VIEW vEmployees AS
SELECT e.EmployeeFirstName, i.EmployeeID, e.EmployeeLastName, e.ManagerID
FROM Employees e
JOIN Inventories i ON i.EmployeeID = e.EmployeeID;   

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

-- Revoke SELECT permission on tables from public group
revoke SELECT on Products to public
revoke SELECT on Categories to public
revoke SELECT on Inventories to public
revoke SELECT on Employees to public

-- Grant SELECT permission on views to public group
GRANT SELECT ON dbo.vProducts TO PUBLIC;
GRANT SELECT ON dbo.vCategories TO PUBLIC;
GRANT SELECT ON dbo.vInventories TO PUBLIC;
GRANT SELECT ON dbo.vEmployees TO PUBLIC;

select * from Products;

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
CREATE VIEW vProductsByCategories AS
SELECT  TOP (20) p.ProductName, c.CategoryName, p.UnitPrice
FROM Products p
JOIN Categories c ON c.CategoryID = p.CategoryID
Order by c.CategoryName, p.ProductName;   

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
CREATE VIEW vInventoriesByProductsByDates AS
SELECT TOP (100) p.ProductName, i.[Count], i.InventoryDate
FROM Inventories i
JOIN Products p ON p.ProductID = i.ProductID
ORDER BY p.ProductName asc, i.InventoryDate asc, i.Count asc;     

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE VIEW vInventoriesByEmployeesByDates AS
SELECT TOP (100) STRING_AGG(CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName),',') as EmployeeName , i.InventoryDate
FROM Employees e
JOIN Inventories i ON i.EmployeeID = e.EmployeeID
GROUP BY i.InventoryDate
ORDER BY i.InventoryDate asc;

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
CREATE VIEW vInventoriesByProductsByCategories AS
SELECT TOP (100) c.CategoryName, p.ProductName, i.InventoryDate, i.count
FROM Inventories i
JOIN Products p ON p.ProductID = i.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
ORDER BY CategoryName ASC, ProductName ASC;

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
CREATE VIEW vInventoriesByProductsByEmployees AS
SELECT TOP (100) c.CategoryName, p.ProductName, i.InventoryDate,i.count, CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) as EmployeeName 
FROM Inventories i
JOIN Products p ON p.ProductID = i.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
JOIN Employees e ON e.EmployeeID = i.EmployeeID
ORDER BY EmployeeName DESC,CategoryName ASC, ProductName ASC;

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
CREATE VIEW vInventoriesForChaiAndChangByEmployees AS
SELECT TOP (100) c.CategoryName, p.ProductName, i.InventoryDate, i.count,CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) as EmployeeName 
FROM Inventories i
JOIN Products p ON p.ProductID = i.ProductID
JOIN Categories c ON c.CategoryID = p.CategoryID
JOIN Employees e ON e.EmployeeID = i.EmployeeID
WHERE i.ProductID IN (SELECT ProductID FROM Products WHERE ProductName = 'Chai' OR ProductName = 'Chang')
ORDER BY i.InventoryDate asc, c.CategoryName asc, p.ProductName asc;

-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
CREATE VIEW vEmployeesByManager AS
SELECT TOP (100) CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) as Employee, CONCAT(m.EmployeeFirstName, ' ', m.EmployeeLastName) AS Manager
FROM Employees e
JOIN Employees m ON e.ManagerID = m.EmployeeID
ORDER BY Manager asc;

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees AS
SELECT DISTINCT c.CategoryID, c.CategoryName, p.ProductID, p.ProductName, p.UnitPrice, e.EmployeeID, CONCAT(e.EmployeeFirstName, ' ', e.EmployeeLastName) AS ManagerName, e.ManagerID
FROM vCategories c
JOIN vProducts p ON p.CategoryID = c.CategoryID
JOIN vInventories i ON i.ProductID = p.ProductID
JOIN vEmployees e ON e.EmployeeID = i.EmployeeID;

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/