create database collections;
use collections;
select * from Artworks;
select count(*) from Artworks

-- How modern are the artworks at the Museum?

--Checking the  null values--
select AccessionNumber,DateAcquired from Artworks
where DateAcquired is null;

--Deleting the uneccesarry rows
delete from Artworks
where DateAcquired is null;

-- How modern are the artworks at the Museum?
SELECT 
    CASE 
        WHEN YEAR(DateAcquired) < 1950 THEN 'Before 1950'
        WHEN YEAR(DateAcquired) BETWEEN 1950 AND 1979 THEN '1950–1979'
        WHEN YEAR(DateAcquired) BETWEEN 1980 AND 1999 THEN '1980–1999'
        WHEN YEAR(DateAcquired) BETWEEN 2000 AND 2009 THEN '2000–2009'
        WHEN YEAR(DateAcquired) >= 2010 THEN '2010–2024 (Modern)'
        ELSE 'Unknown'
    END AS AcquisitionCluster, COUNT(*) AS ArtworkCount
FROM 
    dbo.ArtWorks
WHERE 
    DateAcquired IS NOT NULL
GROUP BY 
    CASE 
        WHEN YEAR(DateAcquired) < 1950 THEN 'Before 1950'
        WHEN YEAR(DateAcquired) BETWEEN 1950 AND 1979 THEN '1950–1979'
        WHEN YEAR(DateAcquired) BETWEEN 1980 AND 1999 THEN '1980–1999'
        WHEN YEAR(DateAcquired) BETWEEN 2000 AND 2009 THEN '2000–2009'
        WHEN YEAR(DateAcquired) >= 2010 THEN '2010–2024 (Modern)'
        ELSE 'Unknown'
    END
ORDER BY  ArtworkCount desc;

--Which artists are featured the most? --

ALTER TABLE Artworks
ALTER COLUMN Artist NVARCHAR(MAX);

SELECT TOP 10 CAST(Artist AS VARCHAR(MAX)) AS artist_name,COUNT(*) AS artwork_count
FROM artworks
WHERE CAST(Artist AS VARCHAR(MAX)) IS NOT NULL AND CAST(Artist AS VARCHAR(MAX)) != ''
GROUP BY CAST(Artist AS VARCHAR(MAX))
ORDER BY artwork_count DESC;

-- Are there any trends in the dates of acquisition?

-- Step 1: Check for missing or placeholder classifications
SELECT Classification ,Medium,CreditLine
FROM Artworks
WHERE Classification IS NULL 
   OR Classification = '' 
   OR Classification = '(not assigned)';

-- Step 2: Yearly classification acquisitions and changes
WITH YearlyAcquisition AS (  SELECT  YEAR(DateAcquired) AS Year, COUNT(*) AS Acquisitions
    FROM dbo.ArtWorks
    WHERE  DateAcquired IS NOT NULL
    GROUP BY   YEAR(DateAcquired))
SELECT Year,Acquisitions,LAG(Acquisitions) OVER (ORDER BY Year) AS PreviousYear,Acquisitions-LAG(Acquisitions) OVER (ORDER BY Year) AS YoY_Change,
    CASE 
        WHEN LAG(Acquisitions) OVER (ORDER BY Year) = 0 THEN NULL
        ELSE ROUND(100.0 * (Acquisitions - LAG(Acquisitions) OVER (ORDER BY Year))     / LAG(Acquisitions) OVER (ORDER BY Year),2)
    END AS YoY_Change_Percent
FROM YearlyAcquisition
ORDER BY Year;

--What types of Artworks are most common
SELECT  Classification, COUNT(*) AS Frequency
FROM artworks
GROUP BY Classification
ORDER BY Frequency DESC;

-- Find the Average Artwork Size Over Time
SELECT  YEAR(DateAcquired) AS Year,
    ROUND( AVG(
            CASE WHEN Depth_cm IS NOT NULL THEN CAST(Height_cm AS FLOAT) * CAST(Width_cm AS FLOAT) * CAST(Depth_cm AS FLOAT)
                ELSE 
                 CAST(Height_cm AS FLOAT) * CAST(Width_cm AS FLOAT) END), 2) AS AvgSize
FROM  Artworks
WHERE  Height_cm IS NOT NULL AND  Width_cm IS NOT NULL AND DateAcquired IS NOT NULL
GROUP BY  YEAR(DateAcquired)
ORDER BY  Year;

--REASON 
--The reason for the query is to calculate the average size of artworks acquired each year, 
--providing insights into trends related to the physical size of the art collection over time, 
--which could help in planning and understanding the nature of the acquisitions (larger or smaller artworks, for example) and
--how they have evolved throughout the years.