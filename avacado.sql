use avacado;

-- Select first 5 rows from table avacado:
SELECT TOP 5 *
FROM avocado;



-- Calculate the total volume of avocados sold:
SELECT SUM(Total_Volume) AS TotalVolumeSold
FROM avocado;



-- Calculate the total number of bags sold:
SELECT SUM(Total_Bags) AS TotalBagsSold
FROM avocado;



-- Calculate the total number of bags sold for each type:
SELECT [Type], SUM(Total_Bags) AS TotalBagsSold
FROM avocado
GROUP BY [Type];



-- Find the maximum and minimum price of avocados:
SELECT MAX(AveragePrice) AS MaxPrice, MIN(AveragePrice) AS MinPrice
FROM avocado;



-- Calculate Total Sales Volume and Revenue by Year and Region:
SELECT year, region, SUM(Total_Volume) AS TotalVolume, SUM(Total_Volume * AveragePrice) AS TotalRevenue
FROM Avocado
GROUP BY year, region;



-- Find the Average Price of Avocado by Type and Year:
SELECT year, type, AVG(AveragePrice) AS AvgPrice
FROM Avocado
GROUP BY year, type;



-- Percentage of Conventional Avocados Sold:
SELECT
    ROUND(
        SUM(CASE WHEN [Type] = 'conventional' THEN Total_Volume ELSE 0 END) * 100.0 /
        SUM(Total_Volume),
        2
    ) AS PercentageOrganicAvocados
FROM avocado;



-- Find the average price and total volume of avocados for each type and region combination:
SELECT [Type], Region, AVG(AveragePrice) AS AvgPrice, SUM(Total_Volume) AS TotalVolume
FROM avocado
GROUP BY [Type], Region;



-- Find the region with the highest total volume of avocados sold:
SELECT TOP 1 Region, SUM(Total_Volume) AS TotalVolumeSold
FROM avocado
GROUP BY Region
ORDER BY TotalVolumeSold DESC;



-- Find the combination of type and region with the highest total revenue:
SELECT TOP 1 [Type], Region, SUM(AveragePrice * Total_Volume) AS TotalRevenue
FROM avocado
GROUP BY [Type], Region
ORDER BY TotalRevenue DESC;



-- Find the type with the highest average price:
SELECT TOP 1 [Type], AVG(AveragePrice) AS AvgPrice
FROM avocado
GROUP BY [Type]
ORDER BY AvgPrice DESC;



-- Get the top 3 regions with the highest total volume of small bags:
SELECT TOP 3 Region, SUM(Small_Bags) AS TotalSmallBags
FROM avocado
GROUP BY Region
ORDER BY TotalSmallBags DESC;



-- Calculate the Percentage of Total Bags by Type and Region:
SELECT region, type, 
       SUM(Total_Bags) AS TotalBags,
       (SUM(Total_Bags) / SUM(SUM(Total_Bags)) OVER (PARTITION BY region)) * 100 AS PercentageOfTotalBags
FROM Avocado
GROUP BY region, type;



-- Get the top 3 types with the highest total volume of large bags:
SELECT TOP 3 [Type], SUM(Large_Bags) AS TotalLargeBags
FROM avocado
GROUP BY [Type]
ORDER BY TotalLargeBags DESC;



-- Calculate the percentage of small bags sold compared to total bags for each region:
SELECT Region, ROUND(CAST(SUM(Small_Bags) AS FLOAT) * 100.0 / SUM(Total_Bags), 2) AS PercentageSmallBags
FROM avocado
GROUP BY Region;



-- Find the regions with a total volume of small bags greater than the total volume of large bags:
SELECT Region
FROM avocado
GROUP BY Region
HAVING SUM(Small_Bags) > SUM(Large_Bags);



-- Calculate the percentage of large bags sold compared to total bags for each type:
SELECT [Type], ROUND(CAST(SUM(Large_Bags) AS FLOAT) * 100.0 / SUM(Total_Bags), 2) AS PercentageLargeBags
FROM avocado
GROUP BY [Type];



-- Identify the Year with the Highest and Lowest Average Price:
SELECT year, AVG(AveragePrice) AS AvgPrice
FROM Avocado
GROUP BY year
ORDER BY AvgPrice DESC;



-- Trend of average avocado price over time:
SELECT Date, AVG("AveragePrice") AS avg_price
FROM avocado
GROUP BY Date
ORDER BY Date;



-- Total volume of avocados sold per month in each region:
SELECT region, DATEPART(MONTH, CONVERT(DATE, Date, 105)) AS month,
       SUM([Total_Volume]) AS total_volume
FROM avocado
GROUP BY region, DATEPART(MONTH, CONVERT(DATE, Date, 105));



-- Find the months with the highest average price:
SELECT DATEPART(MONTH, [Date]) AS Month, AVG(AveragePrice) AS AvgPrice
FROM avocado
GROUP BY DATEPART(MONTH, [Date])
ORDER BY AvgPrice DESC
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;



-- Find the regions with an average price above the overall average price:
SELECT Region, AVG(AveragePrice) AS AvgPricePerRegion
FROM avocado
GROUP BY Region
HAVING AVG(AveragePrice) > (SELECT AVG(AveragePrice) FROM avocado);



-- Find the minimum, maximum, and standard deviation of prices for each type
SELECT
    [Type],
    AVG(AveragePrice) AS AvgPrice,
    MIN(AveragePrice) AS MinPrice,
    MAX(AveragePrice) AS MaxPrice,
    STDEV(AveragePrice) AS StdDevPrice
FROM
    avocado
GROUP BY
    [Type];



-- Calculate the year-over-year growth rate of total volume for each region:
SELECT
    r1.Region,
    r1.Year,
    ROUND(
        CASE WHEN COALESCE(r2.TotalVolume, 0) = 0 THEN 0
             ELSE (CAST(r1.TotalVolume - COALESCE(r2.TotalVolume, 0) AS FLOAT) * 100.0 / COALESCE(r2.TotalVolume, 1))
        END,
        2
    ) AS YoYGrowthRate
FROM
    (
        SELECT Region, Year, SUM(Total_Volume) AS TotalVolume
        FROM avocado
        GROUP BY Region, Year
    ) r1
    LEFT JOIN
    (
        SELECT Region, Year, SUM(Total_Volume) AS TotalVolume
        FROM avocado
        GROUP BY Region, Year
    ) r2
    ON r1.Region = r2.Region AND r1.Year = r2.Year + 1
ORDER BY
    r1.Region, r1.Year;



-- Find the regions with the highest year-over-year growth rate in total revenue:
SELECT
    r1.Region,
    r1.Year,
    ROUND(
        CASE WHEN COALESCE(r2.TotalRevenue, 0) = 0 THEN 0
             ELSE (CAST(r1.TotalRevenue - COALESCE(r2.TotalRevenue, 0) AS FLOAT) * 100.0 / COALESCE(r2.TotalRevenue, 1))
        END,
        2
    ) AS YoYGrowthRateRevenue
FROM
    (
        SELECT Region, Year, SUM(AveragePrice * Total_Volume) AS TotalRevenue
        FROM avocado
        GROUP BY Region, Year
    ) r1
    LEFT JOIN
    (
        SELECT Region, Year, SUM(AveragePrice * Total_Volume) AS TotalRevenue
        FROM avocado
        GROUP BY Region, Year
    ) r2
    ON r1.Region = r2.Region AND r1.Year = r2.Year + 1
ORDER BY
    YoYGrowthRateRevenue DESC;