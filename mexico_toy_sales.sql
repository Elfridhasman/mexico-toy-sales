-- Active: 1666274076413@@127.0.0.1@3306@mexico_toy_sales
--
-- Use database mexico_toy_sales;
USE mexico_toy_sales;

-- Show all table in mexico_toy_sales database
SHOW TABLES;

-- Check the data type for each column in the table
DESC stores;
DESC sales;
DESC inventory;
DESC products;

-- Select data each table

SELECT * FROM stores;
SELECT * FROM inventory;
SELECT * FROM sales LIMIT 10;
SELECT * FROM products;

-- Replace $ sign
UPDATE products SET `Product_Price` = REPLACE(`Product_Price`,'$','');
UPDATE products SET `Product_Cost` = REPLACE(`Product_Cost`,'$','');

-- Sum products price
SELECT SUM(`Product_Price`) FROM products;

-- Change data type date column in sales table to DATE
ALTER TABLE sales MODIFY Date DATE;

-- Change data type Store_Open_Date column in stores table to DATE
ALTER TABLE stores MODIFY Store_Open_Date DATE;

-- Try to count `Sale_ID` GROUP BY YEAR 
SELECT YEAR(date), COUNT(sale_id) FROM sales
GROUP BY YEAR(date);

-- Sum of total sales
SELECT 
    ROUND(SUM(sales.`Units` * products.`Product_Price`),0) AS total_sales
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`;

-- COunt of total units
SELECT 
    SUM(sales.`Units`) AS count_of_units
FROM sales;

-- Sum total sales by product `Product_Category` (Join table products & sales)
SELECT products.`Product_Category`,
    ROUND(SUM(sales.`Units` * products.`Product_Price`),0) AS total_sales
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`
GROUP BY products.`Product_Category`
ORDER BY total_sales DESC;

-- Latest Month Profit --

-- Set variable for get max year and max month

-- Method 1

SET @year := (SELECT MAX(YEAR(`Date`)) FROM sales);
SET @month := (SELECT MAX(MONTH(`Date`)) FROM sales WHERE YEAR(`Date`) = @year);

SELECT 
    ROUND(SUM(sales.`Units` * products.`Product_Price`),0) - ROUND(SUM(sales.`Units` * products.`Product_Cost`),0) AS Profit
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`
WHERE YEAR(DATE) = @year AND MONTH(`Date`) = @month;

-- Method 2 (You can get the same number)

SELECT 
    ROUND(SUM(sales.`Units` * products.`Product_Price`),0) - ROUND(SUM(sales.`Units` * products.`Product_Cost`),0) AS Profit
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`
WHERE YEAR(DATE) = (SELECT MAX(YEAR(`Date`)) FROM sales) 
    AND MONTH(DATE) = (SELECT MAX(MONTH(`Date`)) 
    FROM sales 
        WHERE YEAR(`Date`) = (SELECT MAX(YEAR(`Date`)) 
        FROM sales) );



-- Previous Month Profit --
SELECT 
    ROUND(SUM(sales.`Units` * products.`Product_Price`),0) - ROUND(SUM(sales.`Units` * products.`Product_Cost`),0) AS Profit
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`
WHERE YEAR(DATE) = (SELECT MAX(YEAR(`Date`)) FROM sales) 
    AND MONTH(DATE) = (SELECT MAX(MONTH(`Date`) -1 ) 
    FROM sales 
        WHERE YEAR(`Date`) = (SELECT MAX(YEAR(`Date`)) 
        FROM sales) );
        
-- Get  Product_Price
SELECT 
    ROUND(SUM(sales.`Units` * products.`Product_Price`),0) AS Product_Price
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`;

-- Get Product_Cost 
SELECT 
    ROUND(SUM(sales.`Units` * products.`Product_Cost`),0) AS Product_Cost
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`;

-- Top 1 sales by `Product_Category` for each `Store_Location`
 SELECT Store_Location, Product_Category, total_sales
 FROM(
    SELECT stores.`Store_Location` AS store_location,
        products.`Product_Category` AS Product_Category,
        ROUND(SUM(sales.`Units` * products.`Product_Price`),0) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY stores.`Store_Location` ORDER BY total_sales DESC) AS rank
    FROM products 
        LEFT JOIN sales ON products.`Product_ID` = sales.`Product_ID`
        LEFT JOIN stores ON sales.`Store_ID` = stores.`Store_ID`
    GROUP BY products.`Product_Category`,
        stores.`Store_Location` 
    ) rank_pdc_by_location
WHERE rank = 1;

-- Total sales group by year and month
SELECT YEAR(sales.`Date`) AS year,
    MONTH(sales.`Date`) AS month,
    ROUND(SUM(sales.`Units` * products.`Product_Price`),0) AS total_sales
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`
GROUP BY year, month
ORDER BY total_sales DESC;

-- Total sales by day name
SELECT DAYNAME(sales.`Date`) AS day_name,
    ROUND(SUM(sales.`Units` * products.`Product_Price`),0) AS total_sales
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`
GROUP BY day_name
ORDER BY total_sales DESC;

SELECT * FROM inventory WHERE `Stock_On_Hand` = 0;

SELECT 
    stores.`Store_Location`,
    SUM(`Stock_On_Hand`) AS Stock_On_Hand
FROM stores 
    LEFT JOIN inventory ON inventory.`Store_ID` = stores.`Store_ID`
    LEFT JOIN products ON products.`Product_ID` = inventory.`Product_ID`
GROUP BY 1;

SELECT `Store_ID`, sto
FROM inventory;

SELECT `Store_ID`,Stock_On_Hand FROM inventory
WHERE Stock_On_Hand = 0;

SELECT COUNT(DISTINCT(`Store_ID`)) FROM inventory;
SELECT COUNT(*) FROM inventory;


SELECT 
    stores.`Store_Location`,
    SUM(`Stock_On_Hand`) AS Stock_On_Hand
FROM stores 
    LEFT JOIN inventory ON inventory.`Store_ID` = stores.`Store_ID`
    LEFT JOIN products ON products.`Product_ID` = inventory.`Product_ID`
GROUP BY 1;

------------------------------------------------------------------------------------
-- How much money is tied up in inventory at the toy stores? How long will it last?
------------------------------------------------------------------------------------


-- Total Stock_On_Hand in inventory
SELECT SUM(`Stock_On_Hand`) FROM inventory;

-- Total money tied up in invenstory
SELECT ROUND(SUM(`Stock_On_Hand` * `Product_Price`),0) AS money_tiedUP_
FROM inventory 
    LEFT JOIN products 
        ON products.`Product_ID` = inventory.`Product_ID`;

-- Total sales 2018
SELECT ROUND(SUM(sales.`Units` * products.`Product_Price`),0)  AS total_sales
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`
WHERE YEAR(`Date`) = 2018;

-- Average total sales per month 2018 
SELECT ROUND(SUM(sales.`Units` * products.`Product_Price`) / COUNT(DISTINCT MONTH(sales.`Date`)),0) AS total_sales
FROM products LEFT JOIN sales 
    ON products.`Product_ID` = sales.`Product_ID`
WHERE YEAR(`Date`) = 2018;

SELECT SUM(`Units`) FROM sales
WHERE YEAR(`Date`) = 2018 AND MONTH(`Date`) = 8;


--------------------------------------------
-- Thank you guys
-- Email : elfridhasman@gmail.com
--------------------------------------------





















