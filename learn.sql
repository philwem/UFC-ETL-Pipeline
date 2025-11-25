


SELECT  DISTINCT
    Event_Id,
    Name,
    Date,
    Location
FROM silver.Events
-+
SELECT 
    Event_Id,
    Name,
    Date,
    Location
FROM silver.Events
WHERE Date >= '2023-01-01'
ORDER BY Date DESC;

SELECT 
    Location,
    COUNT(*) AS Event_Count,
    MIN(Date) AS First_Event,
    MAX(Date) AS Latest_Event
FROM silver.Events
WHERE Date >= '2023-01-01'
GROUP BY Location
ORDER BY Event_Count DESC;


SELECT 
    Event_Id,
    Name,
    Date,
    Location,
    COUNT(*) OVER (PARTITION BY Location) AS Events_At_Location
FROM silver.Events
WHERE Date >= '2023-01-01'
ORDER BY Date DESC;

SELECT 
    Location,
    COUNT(*) AS Event_Count,
    MIN(Date) AS First_Event,
    MAX(Date) AS Latest_Event
FROM silver.Events
WHERE Date >= '2023-01-01'
GROUP BY Location
HAVING COUNT(*) > 5
ORDER BY Event_Count DESC;