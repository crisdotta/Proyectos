															/*Cleaning the table*/
--Drop unnecesary cols
ALTER TABLE dbo.ifood DROP COLUMN F31;
ALTER TABLE dbo.ifood DROP COLUMN F32;
ALTER TABLE dbo.ifood DROP COLUMN F33;
ALTER TABLE dbo.ifood DROP COLUMN F34;
--Testing function to remove 00:00:00 (hours) from Date col
SELECT CAST(DateSinceCostumer AS Date) AS fecha_sin_hora 
FROM ifood;
--Adding new col to later remove the hour from Date col
ALTER TABLE ifood
ADD DateSinceCustomer DATE;
UPDATE ifood 
SET DateSinceCustomer = CAST(DateSinceCostumer AS Date);
-- Removing the Date col with the hours 
ALTER TABLE dbo.ifood 
DROP COLUMN DateSinceCostumer;
																	/*EDA*/
/*Date related analysis*/
-- Quantity of customers that joined based on month and year
SELECT FORMAT(DateSinceCustomer, 'MM-yyyy') AS 'DateSinceCustomer',
	   COUNT(FORMAT(DateSinceCustomer, 'MM-yyyy')) AS QuantityOfCustomers
FROM ifood
GROUP BY FORMAT(DateSinceCustomer, 'MM-yyyy')
ORDER BY COUNT(FORMAT(DateSinceCustomer, 'MM-yyyy')) DESC;
-- Number of customers that joined based on month 
SELECT FORMAT(DateSinceCustomer, 'MM') AS 'DateSinceCustomer',
	   COUNT(FORMAT(DateSinceCustomer, 'MM')) AS QuantityOfCustomers
FROM ifood
GROUP BY FORMAT(DateSinceCustomer, 'MM')
ORDER BY COUNT(FORMAT(DateSinceCustomer, 'MM')) DESC;
-- Number of customers that joined based on year 
SELECT FORMAT(DateSinceCustomer, 'yyyy') AS 'DateSinceCustomer',
	   COUNT(FORMAT(DateSinceCustomer, 'yyyy')) AS QuantityOfCustomers
FROM ifood
GROUP BY FORMAT(DateSinceCustomer, 'yyyy')
ORDER BY COUNT(FORMAT(DateSinceCustomer, 'yyyy')) DESC;
-- Average client age
SELECT ROUND(AVG(age),0) as average_age
FROM ifood;
-- Average income
SELECT ROUND(AVG(income),2) as average_income
FROM ifood;
-- Family composition
SELECT family, 
	   COUNT(family) as count_family, 
	   CAST(COUNT(family) * 100.0 / SUM(COUNT(family)) OVER () AS DECIMAL(10,2)) AS porcentaje 
FROM ifood
GROUP BY family
ORDER BY family DESC;
--Average number of days since the last purchase
SELECT ROUND(AVG([DaySinceLastPurchase]),0) as avg_days_since_last_purchase
FROM ifood;
--Demographic breakdown of purchased products
SELECT ROUND(AVG([AmountWines]),2) as avg_wineBought,
	   ROUND(AVG([AmountFruits]),2)as avg_fruitBought,
	   ROUND(AVG([AmountMeatProducts]),2) as avg_meatBought,
	   ROUND(AVG([AmountFishProducts]),2) as avg_fishBought,
	   ROUND(AVG([AmountSweetProducts]),2) as avg_sweetBought,
	   ROUND(AVG([AmountGoldProds]),2) as avg_goldBought
FROM ifood;
-- Based on family
SELECT family,
	   ROUND(AVG([AmountWines]),2) as avg_wineBought,
	   ROUND(AVG([AmountFruits]),2)as avg_fruitBought,
	   ROUND(AVG([AmountMeatProducts]),2) as avg_meatBought,
	   ROUND(AVG([AmountFishProducts]),2) as avg_fishBought,
	   ROUND(AVG([AmountSweetProducts]),2) as avg_sweetBought,
	   ROUND(AVG([AmountGoldProds]),2) as avg_goldBought
FROM ifood
GROUP BY family; 
-- Based on age
SELECT [AgeGroup],
	   ROUND(AVG([AmountWines]),2) as avg_wineBought,
	   ROUND(AVG([AmountFruits]),2)as avg_fruitBought,
	   ROUND(AVG([AmountMeatProducts]),2) as avg_meatBought,
	   ROUND(AVG([AmountFishProducts]),2) as avg_fishBought,
	   ROUND(AVG([AmountSweetProducts]),2) as avg_sweetBought,
	   ROUND(AVG([AmountGoldProds]),2) as avg_goldBought
FROM ifood
GROUP BY [AgeGroup]
ORDER BY 2 DESC;
-- Total products
SELECT SUM([MntTotal]) 
FROM ifood;
-- Exploratory Data Analysis (EDA) of purchase channels and their effectiveness
SELECT [NumDealsPurchases],[NumWebPurchases],[NumCatalogPurchases],[NumStorePurchases]
FROM ifood;
-- How many purchases are made in each channel
SELECT SUM([NumDealsPurchases]) DealsSum,
	   SUM([NumWebPurchases]) WebSum,
	   SUM([NumCatalogPurchases]) CatalogSum,
	   SUM([NumStorePurchases]) StoreSum
FROM ifood;
-- Based on age
SELECT AgeGroup,
	   SUM([NumDealsPurchases]) DealsSum,
	   SUM([NumWebPurchases]) WebSum,
	   SUM([NumCatalogPurchases]) CatalogSum,
	   SUM([NumStorePurchases]) StoreSum
FROM ifood
GROUP BY AgeGroup;
-- Based on family
SELECT Family,SUM([NumDealsPurchases]) DealsSum,
			  SUM([NumWebPurchases]) WebSum,
			  SUM([NumCatalogPurchases]) CatalogSum,
			  SUM([NumStorePurchases]) StoreSum
FROM ifood
GROUP BY family;

-- EDA of campaign effectiveness (How many accepted the campaign and how many did not accept it)
SELECT  SUM(CASE WHEN [AcceptedCampaign1] > 0 THEN 1 ELSE 0 END ) cmp1,
		SUM(CASE WHEN [AcceptedCampaign2] > 0 THEN 1 ELSE 0 END ) cmp2,
		SUM(CASE WHEN [AcceptedCampaign3] > 0 THEN 1 ELSE 0 END ) cmp3,
		SUM(CASE WHEN [AcceptedCampaign4] > 0 THEN 1 ELSE 0 END ) cmp4,
		SUM(CASE WHEN [AcceptedCampaign5] > 0 THEN 1 ELSE 0 END ) cmp5,
		SUM(CASE WHEN [AcceptedLastCampaign] > 0 THEN 1 ELSE 0 END ) lastcmp
FROM ifood
UNION 
SELECT  SUM(CASE WHEN [AcceptedCampaign1] = 0 THEN 1 ELSE 0 END ) cmp1,
		SUM(CASE WHEN [AcceptedCampaign2] = 0 THEN 1 ELSE 0 END ) cmp2,
		SUM(CASE WHEN [AcceptedCampaign3] = 0 THEN 1 ELSE 0 END ) cmp3,
		SUM(CASE WHEN [AcceptedCampaign4] = 0 THEN 1 ELSE 0 END ) cmp4,
		SUM(CASE WHEN [AcceptedCampaign5] = 0 THEN 1 ELSE 0 END ) cmp5,
		SUM(CASE WHEN [AcceptedLastCampaign] = 0 THEN 1 ELSE 0 END ) lastcmp
FROM ifood;
-- Campaign acceptance ratio
SELECT  CONCAT(CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign1] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign1]),2) AS DECIMAL(10,2)),'%') cmp1,
		CONCAT(CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign2] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign2]),2) AS DECIMAL(10,2)),'%') cmp2,
		CONCAT(CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign3] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign3]),2) AS DECIMAL(10,2)),'%') cmp3,
		CONCAT(CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign4] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign4]),2) AS DECIMAL(10,2)),'%') cmp4,
		CONCAT(CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign5] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign5]),2) AS DECIMAL(10,2)),'%') cmp5,
		CONCAT(CAST(ROUND(SUM(CASE WHEN [AcceptedLastCampaign] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedLastCampaign]),2) AS DECIMAL(10,2)),'%') lastcmp
FROM ifood;
-- Average acceptance ratio
WITH CTE AS(
SELECT  CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign1] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign1]),2) AS DECIMAL(10,2)) cmp1,
		CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign2] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign2]),2) AS DECIMAL(10,2)) cmp2,
		CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign3] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign3]),2) AS DECIMAL(10,2)) cmp3,
		CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign4] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign4]),2) AS DECIMAL(10,2)) cmp4,
		CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign5] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign5]),2) AS DECIMAL(10,2)) cmp5,
		CAST(ROUND(SUM(CASE WHEN [AcceptedLastCampaign] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedLastCampaign]),2) AS DECIMAL(10,2)) lastcmp
FROM ifood)
SELECT CAST(ROUND((AVG(cmp1)+AVG(cmp2)+AVG(cmp3)+AVG(cmp4)+AVG(cmp5)+AVG(lastcmp)) / 6,2) AS DECIMAL(10,2))  AS AVGcmp FROM CTE;
-- Which campaign meets the average acceptance ratio? This shows which campaign was effective and its percentage difference
WITH CTE_child AS(
SELECT  CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign1] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign1]),2) AS DECIMAL(10,2)) cmp1,
		CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign2] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign2]),2) AS DECIMAL(10,2)) cmp2,
		CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign3] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign3]),2) AS DECIMAL(10,2)) cmp3,
		CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign4] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign4]),2) AS DECIMAL(10,2)) cmp4,
		CAST(ROUND(SUM(CASE WHEN [AcceptedCampaign5] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedCampaign5]),2) AS DECIMAL(10,2)) cmp5,
		CAST(ROUND(SUM(CASE WHEN [AcceptedLastCampaign] > 0 THEN 1.0 ELSE 0 END )  *100.0/COUNT([AcceptedLastCampaign]),2) AS DECIMAL(10,2)) lastcmp
FROM ifood),
CTE_Parent AS(
	SELECT CAST(ROUND((AVG(cmp1)+AVG(cmp2)+AVG(cmp3)+AVG(cmp4)+AVG(cmp5)+AVG(lastcmp)) / 6,2) AS DECIMAL(10,2))  AS AVGcmp 
	FROM CTE_child
)
	SELECT 
		Campaign,
		Campaign_Percentage,
		Percentage_Difference,
		DENSE_RANK() OVER (ORDER BY Campaign_Percentage DESC) AS Rank
FROM (
	SELECT 
        'cmp1' AS Campaign,
        cmp1 AS Campaign_Percentage,
        CAST(ROUND((cmp1 - (SELECT AVGcmp FROM CTE_Parent)) / (SELECT AVGcmp FROM CTE_Parent) * 100, 2) AS DECIMAL(10,2)) AS Percentage_Difference
    FROM CTE_child
    UNION ALL
    SELECT 
        'cmp2' AS Campaign,
        cmp2 AS Campaign_Percentage,
        CAST(ROUND((cmp2 - (SELECT AVGcmp FROM CTE_Parent)) / (SELECT AVGcmp FROM CTE_Parent) * 100, 2) AS DECIMAL(10,2)) AS Percentage_Difference
    FROM CTE_child
    UNION ALL
    SELECT 
        'cmp3' AS Campaign,
        cmp3 AS Campaign_Percentage,
        CAST(ROUND((cmp3 - (SELECT AVGcmp FROM CTE_Parent)) / (SELECT AVGcmp FROM CTE_Parent) * 100, 2) AS DECIMAL(10,2)) AS Percentage_Difference
    FROM CTE_child
    UNION ALL
    SELECT 
        'cmp4' AS Campaign,
        cmp4 AS Campaign_Percentage,
        CAST(ROUND((cmp4 - (SELECT AVGcmp FROM CTE_Parent)) / (SELECT AVGcmp FROM CTE_Parent) * 100, 2) AS DECIMAL(10,2)) AS Percentage_Difference
    FROM CTE_child
    UNION ALL
    SELECT 
        'cmp5' AS Campaign,
        cmp5 AS Campaign_Percentage,
        CAST(ROUND((cmp5 - (SELECT AVGcmp FROM CTE_Parent)) / (SELECT AVGcmp FROM CTE_Parent) * 100, 2) AS DECIMAL(10,2)) AS Percentage_Difference
    FROM CTE_child
    UNION ALL
    SELECT 
        'lastcmp' AS Campaign,
        lastcmp AS Campaign_Percentage,
        CAST(ROUND((lastcmp - (SELECT AVGcmp FROM CTE_Parent)) / (SELECT AVGcmp FROM CTE_Parent) * 100, 2) AS DECIMAL(10,2)) AS Percentage_Difference
    FROM CTE_child
) AS Campaigns;
-- Total web visits
SELECT SUM([NumWebVisitsMonth]) as totalWebVisits
FROM ifood;
-- Based on age
SELECT AgeGroup, 
	   SUM([NumWebVisitsMonth]) as totalVisits,
	   ROUND((SUM([NumWebVisitsMonth])/(SELECT SUM([NumWebVisitsMonth]) FROM ifood))*100.00,2) as visitsPercentage
FROM ifood
GROUP BY AgeGroup;
-- Based on family
SELECT family, 
	   SUM([NumWebVisitsMonth]) as totalVisits,
	   ROUND((SUM([NumWebVisitsMonth])/(SELECT SUM([NumWebVisitsMonth]) FROM ifood))*100.00,2) as visitsPercentage
FROM ifood
GROUP BY family;
-- Total complains
SELECT SUM(Complain) as totalComplains, COUNT(Complain) as countOfRegisters,ROUND((SUM(Complain)/COUNT(Complain))*100,2) as percentageOfComplains
FROM ifood;
-- GENERAL SELECT
SELECT * FROM ifood;