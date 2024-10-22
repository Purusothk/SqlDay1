

--You need to create a stored procedure that retrieves a list of all customers who have purchased a specific product.
--consider below tables Customers, Orders,Order_items and Products



CREATE PROC customerSpecificProductWithProductName1
(
    @productId INT  
)
AS
BEGIN
select distinct sc.customer_id, concat(sc.first_name,' ' ,sc.last_name) as name, sc.email, p.product_name 
from sales.customers sc 
join sales.orders so ON sc.customer_id = so.customer_id
join sales.order_items oi ON so.order_id = oi.order_id
join production.products p ON oi.product_id = p.product_id
WHERE p.product_id = @productId;
end;


exec customerSpecificProductWithProductName1 @productId=100;








--Create a stored procedure,it should return a list of all customers who have purchased the specified product, 
--including customer details like CustomerID, CustomerName, and PurchaseDate.
--The procedure should take a ProductID as an input parameter.


CREATE PROC customerSpecificProductWithCustomerDetails
(
    @productId INT  
)
AS
BEGIN
select distinct sc.customer_id, concat(sc.first_name,' ' ,sc.last_name) as Name,so.order_date AS PurchaseDate 
from sales.customers sc 
join sales.orders so ON sc.customer_id = so.customer_id
join sales.order_items oi ON so.order_id = oi.order_id
join production.products p ON oi.product_id = p.product_id
WHERE p.product_id = @productId;
end;


exec customerSpecificProductWithCustomerDetails @productId=11






--CREATE TABLE Department with the below columns
--  ID,Name
--populate with test data
--CREATE TABLE Employee with the below columns
--  ID,Name,Gender,DOB,DeptId
--populate with test data
--a) Create a procedure to update the Employee details in the Employee table based on the Employee id.
--b) Create a Procedure to get the employee information bypassing the employee gender and department id from the Employee table
--c) Create a Procedure to get the Count of Employee based on Gender(input)

create table Department(
	Id int primary key,
	Name varchar(25)
)
create table Employee(
	Id int,
	Name varchar(25),
	Gender varchar(10),
	DOB date,
	DeptId int,
	FOREIGN KEY (DeptId) REFERENCES Department(Id)
)

INSERT INTO Department (Id, Name) VALUES (1, 'HR'), (2, 'IT'), (3, 'Finance');

-- Insert test data for Employee
INSERT INTO Employee (Id, Name, Gender, DOB, DeptId) 
VALUES (1, 'John Doe', 'Male', '1990-05-10', 1),
       (2, 'Jane Smith', 'Female', '1985-03-22', 2),
       (3, 'David Brown', 'Male', '1988-08-19', 3),
       (4, 'Emily Johnson', 'Female', '1992-11-01', 2);




--a) Create a procedure to update the Employee details in the Employee table based on the Employee id.
create proc UpdateEmployeeDetails(
	@EmployeeId int,
	@name varchar(25),
	@gender varchar(10),
	@dob date,
	@DeptId int
)
as begin 
update Employee set 
Name=@name,
Gender=@gender,
Dob=@dob,
DeptId=@DeptId
where Id=@EmployeeId;
end
EXEC UpdateEmployeeDetails @EmployeeId = 1, @Name = 'John Updated', @Gender = 'Male', @DOB = '1990-05-10', @DeptId = 1;



--b) Create a Procedure to get the employee information bypassing the employee gender and department id from the Employee table

create proc EmplInfo (
	@gender varchar(10),
	@deptId int
)
as begin 
select * from Employee where Gender= @gender and DeptId = @deptId
end
EXEC EmplInfo @Gender = 'Female', @DeptId = 2;




--c) Create a Procedure to get the Count of Employee based on Gender(input)
create proc GetEmployeeCountByGender
(
    @gender varchar(10)
)
as
begin
    select count(*) AS EmployeeCount
    from Employee
    where Gender = @gender;
end;

EXEC GetEmployeeCountByGender @Gender = 'Male';




--create function
create function getPrdtById(@productId int)
returns table
as
return (select * from production.products where product_id= @productId)
select * from getPrdtById(3)







create function getAllProducts()
returns int 
as
begin
return (select count(*) from production.products)
end
print dbo.getAllProducts()




--create a Multistatement table valued function 
--that calculates the total sales for each product, considering quantity and price.

create function dbo.totalSalesForEachProduct()
returns @ProductSales table(
	productId int,
	productName varchar(255),
	totalSales decimal(10,2)
)

as begin
	insert into @ProductSales (productId,productName,totalSales)
	select 
		p.product_id as productId,
		p.product_name as productName,
		sum(oi.quantity * oi.list_price) as totalSales
		from production.products p join sales.order_items oi
		on p.product_id = oi.product_id group by p.product_name,p.product_id;
	return;
end

SELECT * FROM dbo.totalSalesForEachProduct();





--6)create a  multi-statement table-valued function that lists all customers along 
--with the total amount they have spent on orders.
 

create function totalAmountSpent1()
returns @AmountSpent table(
	customer_id int,
	Name varchar(255),
	Amount decimal(10,2)
)
as begin
Insert into @AmountSpent (customer_id,Name,Amount)
select 
	c.customer_id,	
	concat(c.first_name,' ',c.last_name) as Name,
	sum(oi.quantity*oi.list_price) as AmountSpent
	from 
		sales.customers c 
	join
	sales.orders o on c.customer_id=o.customer_id
	join 
	sales.order_items oi on oi.order_id=o.order_id
	group by 
		c.customer_id, c.first_name,c.last_name;
	return;
end

SELECT * FROM dbo.totalAmountSpent1();
