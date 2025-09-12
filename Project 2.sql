--PROJECT 2

--1

WITH TBL 
AS
(
SELECT YEAR(SI.InvoiceDate) AS "InvoiceYear"
		,SUM(IL.Quantity*IL.UnitPrice) AS "IncomePerPrice"
		,COUNT(DISTINCT MONTH(InvoiceDate)) AS NumberOfDistinctMonths
FROM Sales.Invoices SI JOIN Sales.InvoiceLines IL
ON SI.InvoiceID=IL.InvoiceID
GROUP BY  YEAR(SI.InvoiceDate)
),
TBL1 AS
(
SELECT *,(IncomePerPrice / NumberOfDistinctMonths) * 12 AS YearlyLinearIncome
FROM TBL
)
SELECT InvoiceYear
,FORMAT(IncomePerPrice,'##,#.00') AS IncomePerPrice
,NumberOfDistinctMonths
,FORMAT(YearlyLinearIncome,'##,#.00') AS YearlyLinearIncome
,CAST(ROUND((YearlyLinearIncome / LAG(YearlyLinearIncome) OVER(ORDER BY YearlyLinearIncome)-1) *100,2) AS MONEY) AS GrowthRate
FROM TBL1
ORDER BY InvoiceYear

GO
--2

WITH T1
AS
(
SELECT YEAR(InvoiceDate) AS "The Year"
	,DATEPART("q",InvoiceDate) AS "The Quarter"
	,SC.CustomerName
	,SUM(ExtendedPrice-TaxAmount) AS "IncomePerQuarterYear"
	,ROW_NUMBER()OVER(PARTITION BY YEAR(InvoiceDate),DATEPART("q",InvoiceDate) ORDER BY SUM(ExtendedPrice-TaxAmount) DESC) AS DNR
FROM Sales.Invoices SI JOIN Sales.Orders SO
ON  SI.OrderID = SO.OrderID
JOIN Sales.Customers SC
ON SO.CustomerID = SC.CustomerID
JOIN Sales.InvoiceLines IL
ON SI.InvoiceID = IL.InvoiceID
GROUP BY YEAR(InvoiceDate) , DATEPART("q",InvoiceDate) , SC.CustomerName
)
SELECT *
FROM T1
WHERE DNR <= 5
ORDER BY [The Year], [The Quarter], [IncomePerQuarterYear] DESC

GO
--3

SELECT TOP 10 WS.StockItemID 
	,WS.StockItemName 
	,SUM(ExtendedPrice-TaxAmount) AS TotalProfit
FROM Sales.InvoiceLines SI JOIN Warehouse.StockItems WS
ON SI.StockItemID = WS.StockItemID
GROUP BY  WS.StockItemID ,WS.StockItemName
ORDER BY TotalProfit DESC

GO
--4

SELECT	ROW_NUMBER() OVER(ORDER BY RecommendedRetailPrice - UnitPrice DESC) AS RN
		,StockItemID 
		,StockItemName
		,UnitPrice
		,RecommendedRetailPrice
		,RecommendedRetailPrice - UnitPrice AS NominalProductProfit
		,DENSE_RANK() OVER(ORDER BY RecommendedRetailPrice - UnitPrice DESC) AS DNR
FROM Warehouse.StockItems
WHERE ValidTo > GETDATE()

GO
--5

WITH SPL
AS
(
SELECT PS.SupplierID ,CONCAT(ps.SupplierID,' ','-',' ', ps.SupplierName) As "SupplierDetails"
		,STRING_AGG(CONCAT(StockItemID,' ',StockItemName),' /,') AS "ProductDetails"
FROM Purchasing.Suppliers PS JOIN Warehouse.StockItems WS
ON PS.SupplierID = WS.SupplierID
GROUP BY CONCAT(ps.SupplierID,' ','-',' ', ps.SupplierName), PS.SupplierID
)
SELECT SupplierDetails ,ProductDetails
FROM SPL
ORDER BY SupplierID

GO
--6

WITH PRICE
AS
(
SELECT SC.CustomerID	
		,AC.CityName
		,ACO.CountryName
		,ACO.Continent
		,ACO.Region
		,SUM(IL.ExtendedPrice) AS TotalExtendedPrice1
FROM Sales.InvoiceLines IL JOIN Sales.Invoices SI
ON IL.InvoiceID = SI.InvoiceID
JOIN Sales.Customers SC
ON SC.CustomerID = SI.CustomerID
JOIN Application.Cities AC
ON SC.PostalCityID = AC.CityID
JOIN Application.StateProvinces AP
ON Ap.StateProvinceID=AC.StateProvinceID
JOIN Application.Countries ACO
ON ACO.CountryID=AP.CountryID
GROUP BY SC.CustomerID ,AC.CityName	,ACO.CountryName ,ACO.Continent ,ACO.Region
)
SELECT TOP 5 CustomerID ,CityName	,CountryName ,Continent	,Region
		,FORMAT(TotalExtendedPrice1, '##,#.00') AS TotalExtendedPrice
FROM PRICE
ORDER BY TotalExtendedPrice1 DESC

GO
--7

WITH PRC
AS
(
SELECT YEAR(InvoiceDate) AS "InvoiceYear"
		,MONTH(InvoiceDate) AS "InvoiceMonth"
		,SUM(Quantity*UnitPrice) AS "MounthlyTotal"
FROM Sales.Invoices SI JOIN Sales.InvoiceLines IL
ON SI.InvoiceID = IL.InvoiceID
GROUP BY YEAR(InvoiceDate) ,MONTH(InvoiceDate)
),
CLT AS
(
SELECT PRC.InvoiceYear ,PRC.InvoiceMonth INT_Invoicemonth ,CAST(InvoiceMonth AS varchar(20))AS Invoicemonth 
		,FORMAT(MounthlyTotal,'##,#.00') AS MounthlyTotal
		,FORMAT(SUM(MounthlyTotal)OVER(PARTITION BY InvoiceYear ORDER BY InvoiceMonth),'##,#.00') AS "CumulativeTotal"
FROM PRC
UNION
SELECT YEAR(InvoiceDate)
		,13
		,'GRAND TOTAL'
		,FORMAT(SUM(Quantity*UnitPrice),'##,#.00')
		,FORMAT(SUM(Quantity*UnitPrice),'##,#.00')
FROM Sales.Invoices SI JOIN Sales.InvoiceLines IL
ON SI.InvoiceID = IL.InvoiceID
GROUP BY YEAR(InvoiceDate)
)
SELECT InvoiceYear, Invoicemonth, MounthlyTotal, CumulativeTotal
FROM CLT
ORDER BY InvoiceYear, INT_Invoicemonth


GO
--8

SELECT MM, [2013],[2014],[2015],[2016]
FROM (SELECT YEAR(OrderDate) AS YY
		,MONTH(OrderDate) AS MM
		,OrderID
FROM Sales.Orders
) AS S
PIVOT (Count(orderid) FOR YY IN ([2013],[2014],[2015],[2016])) PVT
ORDER BY MM

GO
--9

WITH T1
AS
(
SELECT SC.CustomerID 
	,SC.CustomerName 
	,SO.OrderDate
	,LAG(OrderDate,1) OVER(PARTITION BY SC.CustomerID ORDER BY OrderDate) AS "PreviousOrderDate"
FROM Sales.Customers SC JOIN Sales.Orders SO
ON SC.CustomerID=SO.CustomerID
),
T2 AS
(
SELECT CustomerID
		,CustomerName
		,OrderDate
		,PreviousOrderDate
		,AVG(DATEDIFF(DD,PreviousOrderDate,OrderDate)) OVER(PARTITION BY CustomerID) AS "AvgDaysBetweenOrders"
		,MAX(OrderDate) OVER(PARTITION BY CustomerID) AS "LastCustOrderDate"
		,MAX(OrderDate) OVER() AS "LastCustOrderDateAll"
		,DATEDIFF(DD,MAX(OrderDate) OVER(PARTITION BY CustomerID),MAX(OrderDate) OVER()) AS "DaysSinceLastOrder"
FROM T1
)
SELECT *
	,CASE
	WHEN DaysSinceLastOrder>2*AvgDaysBetweenOrders THEN 'Potential Churn'
	ELSE 'Active'
	END AS "CustomerStatus"
FROM T2

GO
--10

WITH T1
AS
(
SELECT CustomerCategoryName 
	,COUNT(DISTINCT CASE 
	WHEN SC.Customername LIKE '%WINGTIP%' THEN 'WINGTIP'
	WHEN SC.Customername LIKE '%TAILSPIN%' THEN 'TAILSPIN' 
	ELSE SC.Customername 
	END) AS "CustomerCount"
FROM Sales.CustomerCategories SCC JOIN Sales.Customers SC
ON scc.CustomerCategoryID = SC.CustomerCategoryID
GROUP BY CustomerCategoryName
)
SELECT * 
	,SUM(CustomerCount) OVER() AS "TotalCastCount"
	,FORMAT(CAST(CustomerCount AS money)/CAST(SUM(CustomerCount) OVER() AS MONEY),'p') AS "DistributionFactor"
FROM T1
ORDER BY CustomerCategoryName

