-- Retail Sales & Customer Analytics | SQL Server
CREATE DATABASE RetailAnalytics;

USE RetailAnalytics;


CREATE TABLE Retail_Sales (
    Order_Date DATE,
    Order_ID VARCHAR(20) PRIMARY KEY,
    Customer_ID VARCHAR(20),
    Product_ID VARCHAR(20),
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Location VARCHAR(50),
    Order_Channel VARCHAR(20),
    Payment_Mode VARCHAR(30),
    Quantity INT,
    Unit_Price DECIMAL(12,2),
    Discount_Rate DECIMAL(5,2),
    Gross_Sales DECIMAL(14,2),
    Net_Sales DECIMAL(14,2),
    Returned BIT,
    Profit DECIMAL(14,2)
);

-- After importing retail_sales_data.csv, run these analysis queries.

-- 1. Overall KPIs
SELECT COUNT(DISTINCT Order_ID) AS Total_Orders,
       COUNT(DISTINCT Customer_ID) AS Total_Customers,
       SUM(Quantity) AS Units_Sold,
       SUM(Net_Sales) AS Revenue,
       SUM(Profit) AS Profit,
       AVG(Net_Sales) AS Avg_Order_Value
FROM Retail_Sales;

-- 2. Monthly sales trend
SELECT YEAR(Order_Date) AS Sales_Year,
       MONTH(Order_Date) AS Sales_Month,
       SUM(Net_Sales) AS Revenue,
       SUM(Profit) AS Profit
FROM Retail_Sales
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Sales_Year, Sales_Month;

-- 3. Category performance
SELECT Category,
       SUM(Net_Sales) AS Revenue,
       SUM(Profit) AS Profit,
       SUM(Quantity) AS Units_Sold,
       AVG(Net_Sales) AS Avg_Order_Value
FROM Retail_Sales
GROUP BY Category
ORDER BY Revenue DESC;

-- 4. Top 10 products by revenue
SELECT TOP 10 Product_Name,
       SUM(Net_Sales) AS Revenue,
       SUM(Profit) AS Profit,
       SUM(Quantity) AS Units_Sold
FROM Retail_Sales
GROUP BY Product_Name
ORDER BY Revenue DESC;

-- 5. Customer ranking
SELECT Customer_ID,
       COUNT(DISTINCT Order_ID) AS Orders,
       SUM(Net_Sales) AS Total_Spent,
       RANK() OVER (ORDER BY SUM(Net_Sales) DESC) AS Customer_Rank
FROM Retail_Sales
GROUP BY Customer_ID
ORDER BY Customer_Rank;

-- 6. Repeat vs one-time customers
WITH C AS (
    SELECT Customer_ID, COUNT(DISTINCT Order_ID) AS Orders
    FROM Retail_Sales
    GROUP BY Customer_ID
)
SELECT CASE WHEN Orders = 1 THEN 'One-Time' ELSE 'Repeat' END AS Customer_Type,
       COUNT(*) AS Customers
FROM C
GROUP BY CASE WHEN Orders = 1 THEN 'One-Time' ELSE 'Repeat' END;

-- 7. Location performance
SELECT Location,
       SUM(Net_Sales) AS Revenue,
       SUM(Profit) AS Profit,
       COUNT(DISTINCT Customer_ID) AS Customers
FROM Retail_Sales
GROUP BY Location
ORDER BY Revenue DESC;

-- 8. Online vs Store
SELECT Order_Channel,
       COUNT(DISTINCT Order_ID) AS Orders,
       SUM(Net_Sales) AS Revenue,
       SUM(Profit) AS Profit,
       AVG(Net_Sales) AS AOV
FROM Retail_Sales
GROUP BY Order_Channel;

-- 9. Return rate
SELECT
    CAST(SUM(CASE WHEN Returned = 1 THEN 1 ELSE 0 END) * 100.0
         / COUNT(*) AS DECIMAL(6,2)) AS Return_Rate_Percent
FROM Retail_Sales;

-- 10. Customers spending above average
SELECT Customer_ID, SUM(Net_Sales) AS Total_Spent
FROM Retail_Sales
GROUP BY Customer_ID
HAVING SUM(Net_Sales) > (SELECT AVG(Customer_Total)
                          FROM (
                              SELECT Customer_ID, SUM(Net_Sales) AS Customer_Total
                              FROM Retail_Sales
                              GROUP BY Customer_ID
                          ) X)
ORDER BY Total_Spent DESC;





SELECT TOP 10 *
FROM Retail_Sales;

SELECT COUNT(*) AS Total_Records
FROM Retail_Sales;

SELECT
    MIN(Order_Date) AS First_Order,
    MAX(Order_Date) AS Last_Order,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Product_ID) AS Total_Products,
    SUM(Net_Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit
FROM Retail_Sales;

SELECT TOP 10 *
FROM Retail_Sales
ORDER BY Order_Date;


--SQL Data Cleaning & Validation
--Check total records

SELECT COUNT(*) AS Total_Records
FROM Retail_Sales;

--Check duplicate Order IDs
SELECT 
    Order_ID,
    COUNT(*) AS Order_Count
FROM Retail_Sales
GROUP BY Order_ID
HAVING COUNT(*) > 1;

--Check NULL values

SELECT
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Null_Order_Date,
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS Null_Order_ID,
    SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS Null_Customer_ID,
    SUM(CASE WHEN Product_ID IS NULL THEN 1 ELSE 0 END) AS Null_Product_ID,
    SUM(CASE WHEN Product_Name IS NULL THEN 1 ELSE 0 END) AS Null_Product_Name,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS Null_Category,
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS Null_Location,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS Null_Quantity,
    SUM(CASE WHEN Net_Sales IS NULL THEN 1 ELSE 0 END) AS Null_Net_Sales,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS Null_Profit
FROM Retail_Sales;

--Check invalid Quantity
SELECT *
FROM Retail_Sales
WHERE Quantity <= 0;

--Check invalid prices
SELECT *
FROM Retail_Sales
WHERE Unit_Price <= 0;

--Check Discount Rate

SELECT
    MIN(Discount_Rate) AS Min_Discount,
    MAX(Discount_Rate) AS Max_Discount
FROM Retail_Sales;

--Validate Gross Sales

SELECT TOP 20
    Order_ID,
    Quantity,
    Unit_Price,
    Gross_Sales,
    Quantity * Unit_Price AS Calculated_Gross_Sales
FROM Retail_Sales
WHERE ABS(Gross_Sales - (Quantity * Unit_Price)) > 0.01;

--Validate Net Sales

SELECT TOP 20
    Order_ID,
    Gross_Sales,
    Discount_Rate,
    Net_Sales,
    Gross_Sales * (1 - Discount_Rate) AS Calculated_Net_Sales
FROM Retail_Sales
WHERE ABS(
    Net_Sales - (Gross_Sales * (1 - Discount_Rate))
) > 0.01;

--Check Returned values

SELECT
    Returned,
    COUNT(*) AS Record_Count
FROM Retail_Sales
GROUP BY Returned;

--0 = Not Returned
--1 = Returned

--Check categories
SELECT
    Category,
    COUNT(*) AS Orders
FROM Retail_Sales
GROUP BY Category
ORDER BY Orders DESC;

--Check locations
SELECT
    Location,
    COUNT(*) AS Orders
FROM Retail_Sales
GROUP BY Location
ORDER BY Orders DESC;

--Final data-quality summary

SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT Order_ID) AS Unique_Orders,
    COUNT(DISTINCT Customer_ID) AS Unique_Customers,
    COUNT(DISTINCT Product_ID) AS Unique_Products,
    SUM(Quantity) AS Total_Units,
    SUM(Net_Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit
FROM Retail_Sales;


--Overall KPI
SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    COUNT(DISTINCT Product_ID) AS Total_Products,
    SUM(Quantity) AS Total_Units_Sold,
    SUM(Net_Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    AVG(Net_Sales) AS Average_Order_Value,
    SUM(Profit) * 100.0 / SUM(Net_Sales) AS Profit_Margin
FROM Retail_Sales;

--Monthly Sales Trend

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    DATENAME(MONTH, Order_Date) AS Month_Name,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    COUNT(DISTINCT Order_ID) AS Orders
FROM Retail_Sales
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date)
ORDER BY
    Sales_Year,
    Sales_Month;

--Category Performance

SELECT
    Category,
    COUNT(DISTINCT Order_ID) AS Orders,
    SUM(Quantity) AS Units_Sold,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    SUM(Profit) * 100.0 / SUM(Net_Sales) AS Profit_Margin
FROM Retail_Sales
GROUP BY Category
ORDER BY Revenue DESC;

--Location Performance

SELECT
    Location,
    COUNT(DISTINCT Order_ID) AS Orders,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    SUM(Profit) * 100.0 / SUM(Net_Sales) AS Profit_Margin
FROM Retail_Sales
GROUP BY Location
ORDER BY Revenue DESC;

--Online vs Store

SELECT
    Order_Channel,
    COUNT(DISTINCT Order_ID) AS Orders,
    SUM(Quantity) AS Units_Sold,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    SUM(Profit) * 100.0 / SUM(Net_Sales) AS Profit_Margin
FROM Retail_Sales
GROUP BY Order_Channel
ORDER BY Revenue DESC;


--Payment Mode Analysis

SELECT
    Payment_Mode,
    COUNT(DISTINCT Order_ID) AS Orders,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit
FROM Retail_Sales
GROUP BY Payment_Mode
ORDER BY Revenue DESC;

--Top 10 Products

SELECT TOP 10
    Product_ID,
    Product_Name,
    Category,
    SUM(Quantity) AS Units_Sold,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit
FROM Retail_Sales
GROUP BY
    Product_ID,
    Product_Name,
    Category
ORDER BY Revenue DESC;

--Return Analysis
SELECT
    Returned,
    COUNT(*) AS Orders,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit
FROM Retail_Sales
GROUP BY Returned;


--Customer Analytics

SELECT
     TOP 10
    Customer_ID,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Total_Units,
    SUM(Net_Sales) AS Total_Spent,
    SUM(Profit) AS Total_Profit,
    AVG(Net_Sales) AS Average_Order_Value
FROM Retail_Sales
GROUP BY Customer_ID
ORDER BY Total_Spent DESC;

--Repeat vs One-Time Customers

WITH CUSTOMER_SUMMARY AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        SUM(Net_Sales) AS Total_Spent
    FROM Retail_Sales
    GROUP BY Customer_ID
)

SELECT
    CASE
        WHEN Total_Orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS Customer_Type,

    COUNT(*) AS Customer_Count,

    SUM(Total_Spent) AS Total_Revenue,

    AVG(Total_Spent) AS Avg_Customer_Spend

FROM CUSTOMER_SUMMARY

GROUP BY
    CASE
        WHEN Total_Orders = 1 THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END

ORDER BY Customer_Count DESC;

--Rank Customers by Spending

WITH CUSTOMER_SUMMARY AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        SUM(Net_Sales) AS Total_Spent,
        SUM(Profit) AS Total_Profit
    FROM Retail_Sales
    GROUP BY Customer_ID
)

SELECT
    Customer_ID,
    Total_Orders,
    Total_Spent,
    Total_Profit,

    RANK() OVER
    (
        ORDER BY Total_Spent DESC
    ) AS Spend_Rank

FROM CUSTOMER_SUMMARY

ORDER BY Spend_Rank;


--Identify Top 10% High-Value Customers

WITH CUSTOMER_SUMMARY AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        SUM(Net_Sales) AS Total_Spent,
        SUM(Profit) AS Total_Profit
    FROM Retail_Sales
    GROUP BY Customer_ID
),

CUSTOMER_SEGMENT AS
(
    SELECT
        Customer_ID,
        Total_Orders,
        Total_Spent,
        Total_Profit,

        NTILE(10) OVER
        (
            ORDER BY Total_Spent DESC
        ) AS Spend_Decile

    FROM CUSTOMER_SUMMARY
)

SELECT
    Customer_ID,
    Total_Orders,
    Total_Spent,
    Total_Profit,
    Spend_Decile,

    CASE
        WHEN Spend_Decile = 1 THEN 'High Value'
        WHEN Spend_Decile IN (2,3,4) THEN 'Medium Value'
        ELSE 'Low Value'
    END AS Customer_Segment

FROM CUSTOMER_SEGMENT

ORDER BY Spend_Decile, Total_Spent DESC;

WITH CUSTOMER_SUMMARY AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        SUM(Net_Sales) AS Total_Spent,
        SUM(Profit) AS Total_Profit
    FROM Retail_Sales
    GROUP BY Customer_ID
),

CUSTOMER_SEGMENT AS
(
    SELECT
        *,
        NTILE(10) OVER
        (
            ORDER BY Total_Spent DESC
        ) AS Spend_Decile
    FROM CUSTOMER_SUMMARY
)

SELECT
    Spend_Decile,
    COUNT(*) AS Customer_Count,
    SUM(Total_Spent) AS Revenue,
    SUM(Total_Profit) AS Profit,
    AVG(Total_Spent) AS Avg_Customer_Spend
FROM CUSTOMER_SEGMENT
GROUP BY Spend_Decile
ORDER BY Spend_Decile;


--Customer Profitability

WITH CUSTOMER_SUMMARY AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        SUM(Net_Sales) AS Total_Spent,
        SUM(Profit) AS Total_Profit
    FROM Retail_Sales
    GROUP BY Customer_ID
)
SELECT TOP 10
    Customer_ID,
    Total_Orders,
    Total_Spent,
    Total_Profit,
    Total_Profit * 100.0 / NULLIF(Total_Spent, 0) AS Profit_Margin
FROM CUSTOMER_SUMMARY
ORDER BY Total_Profit DESC;

--Identify Loss-Making Customers

WITH CUSTOMER_SUMMARY AS
(
    SELECT
        Customer_ID,
        COUNT(DISTINCT Order_ID) AS Total_Orders,
        SUM(Net_Sales) AS Total_Spent,
        SUM(Profit) AS Total_Profit
    FROM Retail_Sales
    GROUP BY Customer_ID
)
SELECT
    Customer_ID,
    Total_Orders,
    Total_Spent,
    Total_Profit,
    Total_Profit * 100.0 / NULLIF(Total_Spent, 0) AS Profit_Margin
FROM CUSTOMER_SUMMARY
WHERE Total_Profit < 0
ORDER BY Total_Profit;

--Analyze Why Customers Are Loss-Making

WITH LOSS_CUSTOMERS AS
(
    SELECT
        Customer_ID
    FROM Retail_Sales
    GROUP BY Customer_ID
    HAVING SUM(Profit) < 0
)
SELECT
    R.Customer_ID,
    COUNT(DISTINCT R.Order_ID) AS Total_Orders,
    SUM(R.Net_Sales) AS Total_Spent,
    SUM(R.Profit) AS Total_Profit,
    AVG(R.Discount_Rate) * 100 AS Avg_Discount_Percent,
    SUM(CASE
            WHEN R.Returned = 1 THEN 1
            ELSE 0
        END) AS Returned_Orders,
    COUNT(*) AS Total_Transactions
FROM Retail_Sales R
INNER JOIN LOSS_CUSTOMERS L
    ON R.Customer_ID = L.Customer_ID
GROUP BY
    R.Customer_ID
ORDER BY
    Total_Profit;


--Product & Category Analysis

--Category Performance

SELECT
    Category,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Units_Sold,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    SUM(Profit) * 100.0 / NULLIF(SUM(Net_Sales), 0) AS Profit_Margin
FROM Retail_Sales
GROUP BY Category
ORDER BY Revenue DESC;

--Product Performance
SELECT
    Product_ID,
    Product_Name,
    Category,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Units_Sold,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    SUM(Profit) * 100.0 / NULLIF(SUM(Net_Sales), 0) AS Profit_Margin
FROM Retail_Sales
GROUP BY
    Product_ID,
    Product_Name,
    Category
ORDER BY Revenue DESC;


--Location Performance
SELECT
    Location,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Units_Sold,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    SUM(Profit) * 100.0 / NULLIF(SUM(Net_Sales), 0) AS Profit_Margin
FROM Retail_Sales
GROUP BY Location
ORDER BY Revenue DESC;


--Order Channel Analysis

SELECT
    Order_Channel,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Units_Sold,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    SUM(Profit) * 100.0 / NULLIF(SUM(Net_Sales), 0) AS Profit_Margin
FROM Retail_Sales
GROUP BY Order_Channel
ORDER BY Revenue DESC;

--Payment Mode Analysis

SELECT
    Payment_Mode,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Units_Sold,
    SUM(Net_Sales) AS Revenue,
    SUM(Profit) AS Profit,
    SUM(Profit) * 100.0 /
        NULLIF(SUM(Net_Sales), 0) AS Profit_Margin
FROM Retail_Sales
GROUP BY Payment_Mode
ORDER BY Revenue DESC;


--Return Analysis by Category

SELECT
    Category,
    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(CASE
        WHEN Returned = 1 THEN 1
        ELSE 0
    END) AS Returned_Orders,

    SUM(Net_Sales) AS Revenue,

    SUM(Profit) AS Profit,

    SUM(CASE
        WHEN Returned = 1 THEN Net_Sales
        ELSE 0
    END) AS Returned_Revenue,

    SUM(CASE
        WHEN Returned = 1 THEN Profit
        ELSE 0
    END) AS Returned_Profit,

    SUM(CASE
        WHEN Returned = 1 THEN 1
        ELSE 0
    END) * 100.0 /
        COUNT(DISTINCT Order_ID) AS Return_Rate

FROM Retail_Sales

GROUP BY Category

ORDER BY Return_Rate DESC;

--Return Analysis by Product

SELECT
    Product_ID,
    Product_Name,
    Category,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(CASE
        WHEN Returned = 1 THEN 1
        ELSE 0
    END) AS Returned_Orders,

    SUM(Net_Sales) AS Revenue,

    SUM(CASE
        WHEN Returned = 1 THEN Net_Sales
        ELSE 0
    END) AS Returned_Revenue,

    SUM(CASE
        WHEN Returned = 1 THEN Profit
        ELSE 0
    END) AS Returned_Profit,

    SUM(CASE
        WHEN Returned = 1 THEN 1
        ELSE 0
    END) * 100.0 /
        COUNT(DISTINCT Order_ID) AS Return_Rate

FROM Retail_Sales

GROUP BY
    Product_ID,
    Product_Name,
    Category

ORDER BY Return_Rate DESC;



--Discount Analysis

SELECT
    CASE
        WHEN Discount_Rate = 0 THEN '0% Discount'
        WHEN Discount_Rate <= 0.05 THEN '1%-5% Discount'
        WHEN Discount_Rate <= 0.10 THEN '6%-10% Discount'
        WHEN Discount_Rate <= 0.15 THEN '11%-15% Discount'
        ELSE '16%+ Discount'
    END AS Discount_Band,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Quantity) AS Units_Sold,

    SUM(Net_Sales) AS Revenue,

    SUM(Profit) AS Profit,

    SUM(Profit) * 100.0 /
        NULLIF(SUM(Net_Sales), 0) AS Profit_Margin

FROM Retail_Sales

GROUP BY
    CASE
        WHEN Discount_Rate = 0 THEN '0% Discount'
        WHEN Discount_Rate <= 0.05 THEN '1%-5% Discount'
        WHEN Discount_Rate <= 0.10 THEN '6%-10% Discount'
        WHEN Discount_Rate <= 0.15 THEN '11%-15% Discount'
        ELSE '16%+ Discount'
    END

ORDER BY
    MIN(Discount_Rate);

 --Return Rate by Order Channel

 SELECT
    Order_Channel,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(CASE
        WHEN Returned = 1 THEN 1
        ELSE 0
    END) AS Returned_Orders,

    SUM(Net_Sales) AS Revenue,

    SUM(Profit) AS Profit,

    SUM(CASE
        WHEN Returned = 1 THEN Net_Sales
        ELSE 0
    END) AS Returned_Revenue,

    SUM(CASE
        WHEN Returned = 1 THEN Profit
        ELSE 0
    END) AS Returned_Profit,

    SUM(CASE
        WHEN Returned = 1 THEN 1
        ELSE 0
    END) * 100.0 /
        COUNT(DISTINCT Order_ID) AS Return_Rate

FROM Retail_Sales

GROUP BY Order_Channel

ORDER BY Return_Rate DESC;

--Monthly Sales Trend
--This is important because your Power BI dashboard will need a proper time-series trend.

SELECT
    YEAR(Order_Date) AS Sales_Year,
    MONTH(Order_Date) AS Sales_Month,
    DATENAME(MONTH, Order_Date) AS Month_Name,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Quantity) AS Units_Sold,

    SUM(Net_Sales) AS Revenue,

    SUM(Profit) AS Profit,

    SUM(Profit) * 100.0 /
        NULLIF(SUM(Net_Sales), 0) AS Profit_Margin

FROM Retail_Sales

GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date),
    DATENAME(MONTH, Order_Date)

ORDER BY
    Sales_Year,
    Sales_Month;

   
--Year-over-Year Analysis
SELECT
    YEAR(Order_Date) AS Sales_Year,

    COUNT(DISTINCT Order_ID) AS Total_Orders,

    SUM(Quantity) AS Units_Sold,

    SUM(Net_Sales) AS Revenue,

    SUM(Profit) AS Profit,

    SUM(Profit) * 100.0 /
        NULLIF(SUM(Net_Sales), 0) AS Profit_Margin

FROM Retail_Sales

GROUP BY YEAR(Order_Date)

ORDER BY Sales_Year;