use supply_db ;

-- **********************************************************************************************************************************

/*
Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/

SELECT DISTINCT Product_Name,Product_Id
FROM product_info p INNER JOIN category c 
ON p.Category_Id=c.Id
WHERE Name LIKE '%Golf%'
ORDER BY Product_Id;

-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.


*/

WITH golf_category AS
(
SELECT Id,Name 
FROM Category WHERE Name LIKE'%Golf%'
)
SELECT Product_Name,ROUND(SUM(Sales),2) AS Sales
FROM golf_category gc INNER JOIN  product_Info p
ON p.Category_Id=gc.Id INNER JOIN ordered_items o
ON p.Product_Id=o.Item_Id
GROUP BY Product_Name
ORDER BY Sales DESC LIMIT 10;
-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/

SELECT segment, COUNT(Order_Id) AS Orders
FROM customer_info ci INNER JOIN orders o
ON ci.Id=o.Customer_Id
GROUP BY segment
ORDER BY Orders DESC;

-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.


*/

WITH sixday_orders AS
(
SELECT Order_Id,Real_Shipping_Days,Segment
FROM orders o INNER JOIN customer_info c 
ON o.Customer_Id=c.Id 
WHERE Real_Shipping_Days=6
),
total_orders AS
(
SELECT COUNT(*) AS Total_Orders FROM sixday_orders
)
SELECT Segment AS customer_segment, ROUND((COUNT(order_ID)/(SELECT Total_Orders FROM total_orders))*100,1) AS percentage_order_split
FROM sixday_orders 
GROUP BY Segment
ORDER BY percentage_order_split DESC;

-- **********************************************************************************************************************************

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		

SELECT SUBSTRING(Order_Date,1,7) AS Month,SUM(Quantity) AS Quantities_Sold, SUM(Sales) AS Sales 
FROM product_info pi INNER JOIN ordered_items oi 
ON pi.Product_Id=oi.Item_Id INNER JOIN orders o
ON oi.Order_Id=o.Order_Id
WHERE LOWER(Product_Name) LIKE '%nike%'
GROUP BY Month 
ORDER BY Month;



-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/

SELECT Product_Id, Product_Name,c.Name AS Category_Name,d.Name AS Department_Name,Product_Price
FROM department d  INNER JOIN product_info pi
ON pi.Department_Id=d.Id INNER JOIN category c 
ON pi.Category_Id=c.Id
ORDER BY Product_Price DESC LIMIT 5;

-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/

WITH cash_ordered_items AS
(
SELECT Item_Id,SUM(Sales) AS Total_Sales, COUNT(DISTINCT oi.Order_Id) AS Order_Count
FROM ordered_items oi INNER JOIN orders o 
ON oi.Order_Id=o.Order_Id
WHERE LOWER(Type)='cash'
GROUP BY Item_Id
ORDER BY Order_Count DESC LIMIT 10
)
SELECT Product_Name,Total_Sales, Order_Count
FROM cash_ordered_items co INNER JOIN product_info pi
ON co.Item_Id=pi.Product_Id
ORDER BY Order_Count DESC, Total_Sales DESC;

-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/

SELECT Order_Id, Type, Real_Shipping_Days,Scheduled_Shipping_Days, Customer_Id, Order_City,
Order_Date, Order_Region,Order_State,Order_Status,Shipping_Mode
FROM orders o INNER JOIN customer_info ci
ON o.Customer_Id=ci.Id
WHERE State='TX' AND LOWER(Street) LIKE '%plaza%' AND NOT(LOWER(Street) LIKE '%mountain%')
ORDER BY Order_Id;
-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/

SELECT COUNT(DISTINCT o.Order_Id) AS Order_Count
FROM department d INNER JOIN product_info pi
ON d.Id=pi.Department_Id
INNER JOIN ordered_items oi 
ON pi.Product_Id=oi.Item_Id
INNER JOIN orders o 
ON oi.Order_Id=o.Order_Id
INNER JOIN customer_info ci
ON o.Customer_Id=ci.Id
WHERE Lower(Segment)='home office' AND (LOWER(d.Name)='apparel' OR LOWER(d.Name)='outdoors');


-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/

WITH Order_List AS
(
SELECT o.Order_State,o.Order_City,COUNT(DISTINCT o.Order_Id) AS Order_Count,d.Name,ci.Segment,
CONCAT(o.Order_State,'-',o.Order_City) AS State_City
FROM department d INNER JOIN product_info pi 
ON d.Id=pi.Department_Id INNER JOIN ordered_items oi
ON pi.Product_Id=oi.Item_Id
INNER JOIN orders o ON oi.Order_Id=o.Order_Id
INNER JOIN customer_info ci 
ON o.Customer_Id=ci.Id
WHERE LOWER(ci.Segment)='home office' AND (LOWER(d.Name)='apparel' OR LOWER(d.Name)='outdoors')
GROUP BY State_City
)
SELECT Order_State,Order_City, Order_Count,
DENSE_RANK() OVER(PARTITION BY Order_State ORDER BY Order_Count DESC) AS City_Rank
FROM Order_List ORDER BY Order_State;
-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/

WITH Estimation_List AS
(
SELECT Order_Id,Shipping_Mode,YEAR(Order_Date) AS Shipping_Year,Order_Status,Segment,
CASE
    WHEN Scheduled_Shipping_Days < Real_Shipping_Days THEN 'UNDERESTIMATED'
    ELSE 'CORRECTLY_ESTIMATED'
END AS Estimation_Type
FROM orders o INNER JOIN customer_info ci
ON o.Customer_Id=ci.Id
WHERE Lower(Segment)='consumer' AND (Order_Status='COMPLETE' OR Order_Status='CLOSED')
),
final_list AS 
(
SELECT Shipping_Mode, Shipping_Year, COUNT(Order_Id) AS Shipping_Underestimated_Order_Count
FROM Estimation_List
WHERE Estimation_Type='UNDERESTIMATED' 
GROUP BY Shipping_Year,Shipping_Mode
)
SELECT Shipping_Mode, Shipping_Underestimated_Order_Count,
ROW_NUMBER() OVER(PARTITION BY Shipping_Year ORDER BY Shipping_Underestimated_Order_Count DESC) AS Shipping_Rank
FROM final_list ;
-- **********************************************************************************************************************************





