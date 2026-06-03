create database wf;
use wf;

CREATE TABLE ProductOrders (
OrderID INT,
OrderDate DATE,
CustomerID INT,
ProductID INT,
ProductName VARCHAR(100),
Category VARCHAR(50),
Quantity INT,
UnitPrice DECIMAL(10,2),
SalesAmount DECIMAL(12,2),
PRIMARY KEY (OrderID, ProductID)
);

INSERT INTO ProductOrders VALUES
(1,'2026-01-05',1001,101,'Laptop','Electronics',2,60000,120000),
(1,'2026-01-05',1001,102,'Mobile','Electronics',1,25000,25000),
(2,'2026-01-10',1002,103,'Printer','Electronics',3,12000,36000),
(3,'2026-01-15',1003,104,'Desk','Furniture',2,8000,16000),
(3,'2026-01-15',1003,105,'Chair','Furniture',4,3000,12000),
(4,'2026-02-05',1004,101,'Laptop','Electronics',1,60000,60000),
(4,'2026-02-05',1004,103,'Printer','Electronics',2,12000,24000),
(5,'2026-02-10',1005,102,'Mobile','Electronics',3,25000,75000),
(5,'2026-02-10',1005,104,'Desk','Furniture',1,8000,8000),
(6,'2026-03-01',1006,105,'Chair','Furniture',5,3000,15000),
(7,'2026-03-05',1007,101,'Laptop','Electronics',2,60000,120000),
(8,'2026-03-12',1008,102,'Mobile','Electronics',4,25000,100000);


-- 1. Generate ROW_NUMBER() for products ordered by SalesAmount descending
-- SELECT SALARY,DEP_ID,
--        ROW_NUMBER() OVER (PARTITION BY dep_id ORDER BY salary DESC) AS RN,
--        RANK() OVER (PARTITION BY dep_id ORDER BY salary DESC) AS RANV,
--        DENSE_RANK() OVER (PARTITION BY dep_id ORDER BY salary DESC) AS DRANV,
--        LAG(salary) OVER (PARTITION BY dep_id ORDER BY salary DESC) AS LAV,
--        LEAD(salary) OVER (PARTITION BY dep_id ORDER BY salary DESC) AS LV,
--        FIRST_VALUE(salary) OVER (PARTITION BY dep_id ORDER BY salary DESC) AS FV,
--        LAST_VALUE(salary) OVER (PARTITION BY dep_id ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LV,
--        NTH_VALUE(salary, 3) OVER (PARTITION BY dep_id ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS NV
-- FROM myemp;

select ProductName, SalesAmount,
	row_number() over (partition by ProductName order by SalesAmount desc) as RN
from ProductOrders;

-- 2. Assign RANK() to products based on total sales.

SELECT ProductName,
       SUM(SalesAmount) AS TotalSales,
       RANK() OVER(
            ORDER BY SUM(SalesAmount) DESC
       ) AS SalesRank
FROM ProductOrders
GROUP BY ProductName;

-- 3. Assign DENSE_RANK() to products based on quantity sold

SELECT ProductName,
       SUM(Quantity) AS TotalQty,
       DENSE_RANK() OVER(
            ORDER BY SUM(Quantity) DESC
       ) AS QtyRank
FROM ProductOrders
GROUP BY ProductName;

-- 4. Find the Top 3 selling products.
SELECT *
FROM (
select ProductName, sum(SalesAmount) as totalSal,
	dense_rank() over( order by sum(SalesAmount) desc ) as D_rnk
    from ProductOrders
    group by ProductName
    
    ) X
where D_rnk <=3;    


-- 5. Display previous SalesAmount using LAG().
SELECT OrderID,
       ProductName,
       SalesAmount,
       LAG(SalesAmount)
       OVER(ORDER BY OrderDate) AS PrevSales
FROM ProductOrders;

-- 6. Display next SalesAmount using LEAD().
SELECT OrderID,
       ProductName,
       SalesAmount,
       LEAD(SalesAmount)
       OVER(ORDER BY OrderDate) AS NextSales
FROM ProductOrders;
-- 7. Calculate running total of SalesAmount by OrderDate.
SELECT OrderDate,
       SalesAmount,
       SUM(SalesAmount)
       OVER(
          ORDER BY OrderDate
       ) AS RunningTotal
FROM ProductOrders;
-- 8. Calculate cumulative sales for each product.
SELECT ProductName,
       OrderDate,
       SalesAmount,
       SUM(SalesAmount)
       OVER(
          PARTITION BY ProductName
          ORDER BY OrderDate
       ) AS CumulativeSales
FROM ProductOrders;
-- 9. Show highest sales in each category using FIRST_VALUE().
SELECT ProductName,
       Category,
       SalesAmount,
       FIRST_VALUE(SalesAmount)
       OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
       ) AS HighestSales
FROM ProductOrders;
-- 10. Show lowest sales in each category using LAST_VALUE().
SELECT ProductName,
       Category,
       SalesAmount,
       LAST_VALUE(SalesAmount)
       OVER(
           PARTITION BY Category
           ORDER BY SalesAmount
           ROWS BETWEEN
           UNBOUNDED PRECEDING
           AND UNBOUNDED FOLLOWING
       ) AS LowestSales
FROM ProductOrders;
-- 11. Calculate difference between current and previous sales.
SELECT ProductName,
       SalesAmount,
       SalesAmount -
       LAG(SalesAmount)
       OVER(ORDER BY OrderDate) AS Difference
FROM ProductOrders;
-- 12. Calculate 3-order moving average sales.
SELECT OrderDate,
       SalesAmount,
       AVG(SalesAmount)
       OVER(
            ORDER BY OrderDate
            ROWS BETWEEN 2 PRECEDING
            AND CURRENT ROW
       ) AS MovingAvg
FROM ProductOrders;
-- 13. Show percentage contribution of each product to total sales.
SELECT ProductName,
       SalesAmount,
       ROUND(
         SalesAmount * 100.0 /
         SUM(SalesAmount) OVER(),
         2
       ) AS ContributionPercent
FROM ProductOrders;
-- 14. Find products whose sales exceed category average.
SELECT *
FROM
(
     SELECT ProductName,
            Category,
            SalesAmount,
            AVG(SalesAmount)
            OVER(
               PARTITION BY Category
            ) AS AvgCategorySales
     FROM ProductOrders
) X
WHERE SalesAmount > AvgCategorySales;
-- 15. Divide products into quartiles using NTILE(4).
SELECT ProductName,
       SalesAmount,
       NTILE(4)
       OVER(
           ORDER BY SalesAmount DESC
       ) AS Quartile
FROM ProductOrders;
-- 16. Find second highest selling product.
SELECT *
FROM
(
     SELECT ProductName,
            SUM(SalesAmount) AS TotalSales,
            DENSE_RANK() OVER(
                 ORDER BY SUM(SalesAmount) DESC
            ) AS RNK
     FROM ProductOrders
     GROUP BY ProductName
) X
WHERE RNK = 2;
-- 17. Compare each product with category leader sales.
SELECT ProductName,
       Category,
       SalesAmount,
       FIRST_VALUE(SalesAmount)
       OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
       ) AS CategoryLeader
FROM ProductOrders;

SELECT ProductName,
       Category,
       SalesAmount,
       FIRST_VALUE(SalesAmount)
       OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
       ) AS CategoryLeader
FROM ProductOrders;

SELECT ProductName,
       Category,
       SalesAmount,

       FIRST_VALUE(SalesAmount)
       OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
       ) AS CategoryLeader,

       FIRST_VALUE(SalesAmount)
       OVER(
           PARTITION BY Category
           ORDER BY SalesAmount DESC
       ) - SalesAmount AS GapToLeader

FROM ProductOrders;
-- 18. Calculate month-over-month sales growth.
-- Month wise total sales calculate kar rahe hain
SELECT DATE_FORMAT(OrderDate,'%Y-%m') AS Month,
       SUM(SalesAmount) AS MonthlySales
FROM ProductOrders
GROUP BY DATE_FORMAT(OrderDate,'%Y-%m');

SELECT Month,
       MonthlySales,

       MonthlySales -
       LAG(MonthlySales)
       OVER(ORDER BY Month) AS MOMGrowth

FROM
(
     -- Month wise total sales
     SELECT DATE_FORMAT(OrderDate,'%Y-%m') AS Month,
            SUM(SalesAmount) AS MonthlySales
     FROM ProductOrders
     GROUP BY DATE_FORMAT(OrderDate,'%Y-%m')
) X;

-- Simple Language 
-- Jan Sales = 200000
-- Feb Sales = 300000
-- Mar Sales = 400000

-- Feb Growth = 300000 - 200000 = 100000
-- Mar Growth = 400000 - 300000 = 100000

-- LAG() = pichle month ki sales laao

-- MOM Growth = Current Month Sales - Previous Month Sales
-- 19. Identify products with consecutive sales increases using LAG().
SELECT ProductName,
       OrderDate,
       SalesAmount,
       CASE
          WHEN SalesAmount >
               LAG(SalesAmount)
               OVER(
                    PARTITION BY ProductName
                    ORDER BY OrderDate
               )
          THEN 'Increase'
          ELSE 'No Increase'
       END AS Status
FROM ProductOrders;

-- 20. Create a sales leaderboard using DENSE_RANK().

SELECT ProductName,
       SUM(SalesAmount) AS TotalSales,
       DENSE_RANK()
       OVER(
            ORDER BY SUM(SalesAmount) DESC
       ) AS LeaderBoardRank
FROM ProductOrders
GROUP BY ProductName;