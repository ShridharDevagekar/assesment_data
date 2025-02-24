1. Overall Sales Summary

SELECT 
    COUNT(TransactionID) AS Total_Transactions,
    SUM(TransactionAmount) AS Total_Revenue,
    AVG(TransactionAmount) AS Avg_Transaction_Value,
    SUM(Quantity) AS Total_Units_Sold,
    AVG(DiscountPercent) AS Avg_Discount
FROM Sales;


Insights:

Total transactions processed
Total revenue generated
Average transaction value
Total units sold
Average discount applied

2. Sales Trend Over Time

SELECT 
    YEAR(TransactionDate) AS Year,
    MONTH(TransactionDate) AS Month,
    SUM(TransactionAmount) AS Monthly_Revenue,
    COUNT(TransactionID) AS Total_Transactions
FROM Sales
GROUP BY YEAR(TransactionDate), MONTH(TransactionDate)
ORDER BY Year, Month;


Insights:

Monthly sales performance trends
Seasonality in sales


3. Top 5 Cities by Revenue

SELECT 
    City,
    SUM(TransactionAmount) AS Total_Revenue,
    COUNT(TransactionID) AS Total_Transactions
FROM Sales
GROUP BY City
ORDER BY Total_Revenue DESC
LIMIT 5;

Insights:

Which cities contribute the most to revenue?
Distribution of transactions across cities


4. Revenue by Store Type

SELECT 
    StoreType,
    SUM(TransactionAmount) AS Total_Revenue,
    COUNT(TransactionID) AS Total_Transactions,
    AVG(TransactionAmount) AS Avg_Sale_Value
FROM Sales
GROUP BY StoreType
ORDER BY Total_Revenue DESC;

Insights:

Performance comparison across different store types

5. Customer Demographics Analysis
SELECT 
    CustomerGender,
    COUNT(DISTINCT CustomerID) AS Unique_Customers,
    AVG(CustomerAge) AS Avg_Customer_Age,
    SUM(TransactionAmount) AS Total_Spent
FROM Sales
GROUP BY CustomerGender;

Insights:

Revenue contribution by gender
Average age of customers

6. Impact of Discounts on Sales

SELECT 
    CASE 
        WHEN DiscountPercent = 0 THEN 'No Discount'
        WHEN DiscountPercent BETWEEN 1 AND 10 THEN '1-10% Discount'
        WHEN DiscountPercent BETWEEN 11 AND 20 THEN '11-20% Discount'
        ELSE 'Above 20% Discount'
    END AS Discount_Range,
    COUNT(TransactionID) AS Total_Transactions,
    SUM(TransactionAmount) AS Total_Revenue
FROM Sales
GROUP BY Discount_Range
ORDER BY Total_Revenue DESC;

Insights:

How different discount ranges impact sales


7. Product-Wise Sales Performance

SELECT 
    ProductName,
    SUM(TransactionAmount) AS Total_Revenue,
    SUM(Quantity) AS Total_Units_Sold
FROM Sales
GROUP BY ProductName
ORDER BY Total_Revenue DESC
LIMIT 10;

Insights:

Top-selling products based on revenue



8. Customer Loyalty Analysis

SELECT 
    CASE 
        WHEN LoyaltyPoints < 100 THEN 'Low Loyalty'
        WHEN LoyaltyPoints BETWEEN 100 AND 500 THEN 'Medium Loyalty'
        ELSE 'High Loyalty'
    END AS Loyalty_Category,
    COUNT(DISTINCT CustomerID) AS Customer_Count,
    SUM(TransactionAmount) AS Total_Revenue
FROM Sales
GROUP BY Loyalty_Category;


SELECT 
    CASE 
        WHEN LoyaltyPoints < 100 THEN 'Low Loyalty'
        WHEN LoyaltyPoints BETWEEN 100 AND 500 THEN 'Medium Loyalty'
        ELSE 'High Loyalty'
    END AS Loyalty_Category,
    COUNT(DISTINCT CustomerID) AS Customer_Count,
    SUM(TransactionAmount) AS Total_Revenue
FROM Sales
GROUP BY Loyalty_Category;

Insights:

Contribution of high-loyalty customers to total revenue

9. Product Returns Analysis

SELECT 
    ProductName,
    COUNT(TransactionID) AS Total_Transactions,
    SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) AS Returns_Count,
    (SUM(CASE WHEN Returned = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(TransactionID)) AS Return_Percentage
FROM Sales
GROUP BY ProductName
ORDER BY Return_Percentage DESC
LIMIT 10;

Insights:

Products with the highest return rates


10. Shipping Performance Analysis

SELECT 
    Region,
    AVG(ShippingCost) AS Avg_Shipping_Cost,
    AVG(DeliveryTimeDays) AS Avg_Delivery_Time
FROM Sales
GROUP BY Region
ORDER BY Avg_Delivery_Time;

Insights:

Which regions have the fastest or slowest delivery times?
Average shipping costs per region

1. Running Total and Moving Average of Sales Over Time

WITH SalesData AS (
    SELECT 
        TransactionDate,
        SUM(TransactionAmount) AS Daily_Sales
    FROM Sales
    GROUP BY TransactionDate
)
SELECT 
    TransactionDate,
    Daily_Sales,
    SUM(Daily_Sales) OVER (ORDER BY TransactionDate) AS Running_Total_Sales,
    AVG(Daily_Sales) OVER (ORDER BY TransactionDate ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS Moving_Avg_7Days
FROM SalesData;

Insights:

Running total of sales over time
7-day moving average to identify trends

2. Identifying Top 3 Products Sold per City (Using RANK)

WITH ProductSales AS (
    SELECT 
        City, 
        ProductName,
        SUM(TransactionAmount) AS Total_Sales,
        RANK() OVER (PARTITION BY City ORDER BY SUM(TransactionAmount) DESC) AS Sales_Rank
    FROM Sales
    GROUP BY City, ProductName
)
SELECT * FROM ProductSales WHERE Sales_Rank <= 3;

Insights:

Top 3 products sold in each city
Helps understand product demand across locations


3. Customer Purchase Behavior - First & Last Purchase Dates

SELECT 
    CustomerID,
    MIN(TransactionDate) AS First_Purchase_Date,
    MAX(TransactionDate) AS Last_Purchase_Date,
    COUNT(TransactionID) AS Total_Transactions,
    SUM(TransactionAmount) AS Total_Spent
FROM Sales
GROUP BY CustomerID;

Insights:

Identifies first-time vs. repeat customers
Helps in customer retention analysis

4. Average Order Value by Customer Segments

SELECT 
    CASE 
        WHEN Total_Spent < 100 THEN 'Low Spender'
        WHEN Total_Spent BETWEEN 100 AND 500 THEN 'Mid Spender'
        ELSE 'High Spender'
    END AS Spending_Category,
    COUNT(CustomerID) AS Customer_Count,
    AVG(Total_Spent) AS Avg_Order_Value
FROM (
    SELECT 
        CustomerID, 
        SUM(TransactionAmount) AS Total_Spent
    FROM Sales
    GROUP BY CustomerID
) AS CustomerSpending
GROUP BY Spending_Category;

Insights:

Segments customers based on spending patterns
Identifies high-value customers

5. Customer Retention - Identifying Churned Customers

WITH CustomerActivity AS (
    SELECT 
        CustomerID,
        MAX(TransactionDate) AS Last_Purchase_Date
    FROM Sales
    GROUP BY CustomerID
)
SELECT 
    CustomerID,
    Last_Purchase_Date,
    DATEDIFF(DAY, Last_Purchase_Date, GETDATE()) AS Days_Since_Last_Purchase
FROM CustomerActivity
WHERE DATEDIFF(DAY, Last_Purchase_Date, GETDATE()) > 90;

Insights:

Identifies customers who haven't purchased in over 90 days
Helps in designing re-engagement campaigns

6. Cohort Analysis - Monthly Customer Retention

WITH CustomerCohort AS (
    SELECT 
        CustomerID,
        MIN(DATE_TRUNC('month', TransactionDate)) AS CohortMonth
    FROM Sales
    GROUP BY CustomerID
), MonthlySales AS (
    SELECT 
        c.CohortMonth,
        DATE_TRUNC('month', s.TransactionDate) AS PurchaseMonth,
        COUNT(DISTINCT s.CustomerID) AS Active_Customers
    FROM Sales s
    JOIN CustomerCohort c ON s.CustomerID = c.CustomerID
    GROUP BY c.CohortMonth, DATE_TRUNC('month', s.TransactionDate)
)
SELECT 
    CohortMonth,
    PurchaseMonth,
    Active_Customers,
    RANK() OVER (PARTITION BY CohortMonth ORDER BY PurchaseMonth) AS Month_Number
FROM MonthlySales;


Insights:

Tracks how many customers continue purchasing in later months
Helps analyze long-term customer retention

7. Detecting Revenue Decline - Quarter-over-Quarter Growth

WITH QuarterlySales AS (
    SELECT 
        YEAR(TransactionDate) AS Year,
        QUARTER(TransactionDate) AS Quarter,
        SUM(TransactionAmount) AS Revenue
    FROM Sales
    GROUP BY YEAR(TransactionDate), QUARTER(TransactionDate)
)
SELECT 
    Year, 
    Quarter,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Year, Quarter) AS Prev_Quarter_Revenue,
    (Revenue - LAG(Revenue) OVER (ORDER BY Year, Quarter)) / NULLIF(LAG(Revenue) OVER (ORDER BY Year, Quarter), 0) * 100 AS Revenue_Growth_Percentage
FROM QuarterlySales;

Insights:

Identifies quarters with revenue decline or growth
Helps in understanding seasonal revenue trends

8. Shipping Efficiency - Delayed Orders by Region

SELECT 
    Region,
    COUNT(TransactionID) AS Total_Orders,
    SUM(CASE WHEN DeliveryTimeDays > 5 THEN 1 ELSE 0 END) AS Delayed_Orders,
    (SUM(CASE WHEN DeliveryTimeDays > 5 THEN 1 ELSE 0 END) * 100.0 / COUNT(TransactionID)) AS Delay_Percentage
FROM Sales
GROUP BY Region
ORDER BY Delay_Percentage DESC;


Insights:

Identifies regions with frequent delivery delays
Helps optimize logistics and supply chain

9. Profitability Analysis by Store Type

SELECT 
    StoreType,
    SUM(TransactionAmount - ShippingCost) AS Net_Revenue,
    AVG(TransactionAmount - ShippingCost) AS Avg_Profit_Per_Order,
    COUNT(TransactionID) AS Total_Orders
FROM Sales
GROUP BY StoreType
ORDER BY Net_Revenue DESC;

Insights:

Calculates net revenue after deducting shipping costs
Helps identify the most profitable store type

10. Predicting Customer Purchase Likelihood (Recency, Frequency, Monetary - RFM Analysis)

WITH RFM AS (
    SELECT 
        CustomerID,
        DATEDIFF(DAY, MAX(TransactionDate), GETDATE()) AS Recency,  -- Days since last purchase
        COUNT(TransactionID) AS Frequency,  -- Number of transactions
        SUM(TransactionAmount) AS Monetary  -- Total amount spent
    FROM Sales
    GROUP BY CustomerID
)
SELECT 
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    NTILE(4) OVER (ORDER BY Recency DESC) AS Recency_Score,
    NTILE(4) OVER (ORDER BY Frequency DESC) AS Frequency_Score,
    NTILE(4) OVER (ORDER BY Monetary DESC) AS Monetary_Score
FROM RFM;


Insights:

Segments customers based on their Recency, Frequency, and Monetary value
Helps target high-value and at-risk customers














