/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/
------------------------------------------------------------
-- 1️⃣ Gold Schema Setup
------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

------------------------------------------------------------
-- 2️⃣ Dim_Fighter
-- Dimension of fighters with stable surrogate key and attributes
------------------------------------------------------------
CREATE OR ALTER  VIEW gold.Dim_Fighter
AS
SELECT
    ABS(CHECKSUM(LOWER(LTRIM(RTRIM(f.Full_Name))))) AS Fighter_SK,
    f.Full_Name,
    f.Nickname,
    s.Gender,
    s.Weight_Class,
    s.Fighting_Style,
    TRY_CAST(f.Ht AS DECIMAL(8,2)) AS Height_cm,
    TRY_CAST(f.Wt AS DECIMAL(8,2)) AS Weight_kg,
    TRY_CAST(f.Reach AS DECIMAL(8,2)) AS Reach_cm,
    f.Stance,
    TRY_CAST(s.W AS INT) AS W,
    TRY_CAST(s.L AS INT) AS L,
    TRY_CAST(s.D AS INT) AS D,
    CASE 
        WHEN TRY_CAST(s.W AS INT) + TRY_CAST(s.L AS INT) > 0 
        THEN CAST((TRY_CAST(s.W AS DECIMAL(10,2)) * 100.0) / NULLIF((TRY_CAST(s.W AS INT) + TRY_CAST(s.L AS INT)),0) AS DECIMAL(5,2))
        ELSE 0 
    END AS Win_Rate,
    TRY_CAST(REPLACE(NULLIF(s.Sig_Str_Percent,''),'%','') AS DECIMAL(8,2)) AS Sig_Str_Accuracy,
    TRY_CAST(REPLACE(NULLIF(s.TD,''),'%','') AS DECIMAL(8,2)) AS Takedown_Accuracy,
    TRY_CAST(NULLIF(s.Sub_Att,'') AS DECIMAL(5,2)) AS Submission_Attempts,
    TRY_CAST(NULLIF(s.Rev,'') AS DECIMAL(5,2)) AS Reversals,
    CAST(GETDATE() AS DATETIME) AS View_Refreshed_At
FROM silver.Fighters f
LEFT JOIN silver.Fighter_Stats s
    ON LTRIM(RTRIM(f.Full_Name)) = LTRIM(RTRIM(s.Full_Name));
GO

------------------------------------------------------------
-- 3️⃣ Dim_Event
-- Dimension for UFC events
------------------------------------------------------------
CREATE OR ALTER VIEW gold.Dim_Event
AS
SELECT
    Event_Id,
    Name AS Event_Name,
    TRY_CAST(Date AS DATE) AS Event_Date,
    Location,
    DATENAME(MONTH, TRY_CAST(Date AS DATE)) AS Event_Month,
    YEAR(TRY_CAST(Date AS DATE)) AS Event_Year,
    DATEPART(QUARTER, TRY_CAST(Date AS DATE)) AS Event_Quarter
FROM silver.Events;
GO

------------------------------------------------------------
-- 4️⃣ Dim_WeightClass
-- Dimension for Weight Classes (if needed for BI/analytics)
------------------------------------------------------------
CREATE OR ALTER VIEW gold.Dim_WeightClass
AS
SELECT DISTINCT
    Weight_Class,
    COUNT(*) OVER(PARTITION BY Weight_Class) AS Total_Fights,
    CAST(GETDATE() AS DATETIME) AS View_Refreshed_At
FROM silver.Fights
WHERE Weight_Class IS NOT NULL;
GO

------------------------------------------------------------
-- Dim_Method
------------------------------------------------------------
CREATE OR ALTER VIEW gold.Dim_Method
AS
SELECT
    ABS(CHECKSUM(LOWER(LTRIM(RTRIM(Method))))) AS Method_SK,
    Method,
    Method_Details,
    CAST(GETDATE() AS DATETIME) AS View_Refreshed_At
FROM (
    SELECT DISTINCT Method, Method_Details
    FROM silver.Fights
    WHERE Method IS NOT NULL
) AS Methods;
GO


------------------------------------------------------------
-- Dim_Date
------------------------------------------------------------
CREATE OR ALTER VIEW gold.Dim_Date
AS
SELECT
    CAST(DateValue AS DATE) AS Date_SK,
    DATEPART(YEAR, DateValue) AS Year,
    DATENAME(MONTH, DateValue) AS Month_Name,
    DATEPART(MONTH, DateValue) AS Month,
    DATEPART(DAY, DateValue) AS Day,
    DATEPART(QUARTER, DateValue) AS Quarter,
    DATENAME(WEEKDAY, DateValue) AS Weekday_Name,
    CAST(GETDATE() AS DATETIME) AS View_Refreshed_At
FROM (
    SELECT DISTINCT TRY_CAST(Date AS DATE) AS DateValue
    FROM silver.Events
    WHERE Date IS NOT NULL
) AS Dates;
GO




------------------------------------------------------------
-- 5️⃣ Fact_Fight_Performance
-- Fact table capturing fight-level metrics with fighter & event keys
------------------------------------------------------------
CREATE OR ALTER VIEW gold.Fact_Fight_Performance
AS
SELECT
    -- Deterministic surrogate key per fight
    ABS(CHECKSUM(LOWER(LTRIM(RTRIM(f.Method))))) AS Method_SK,
    CAST(e.Date AS DATE) AS Date_SK,  -- ⬅️ Changed from f.Event_Date to e.Date
    
    -- Foreign keys
    ABS(CHECKSUM(LOWER(LTRIM(RTRIM(f.Fighter_1))))) AS Fighter_1_SK,
    ABS(CHECKSUM(LOWER(LTRIM(RTRIM(f.Fighter_2))))) AS Fighter_2_SK,
    f.Event_Id AS Event_SK,
    f.Weight_Class,
    
    -- Fight results
    f.Result_1,
    f.Result_2,
    CASE 
        WHEN LTRIM(RTRIM(f.Result_1)) = 'W' THEN LTRIM(RTRIM(f.Fighter_1))
        WHEN LTRIM(RTRIM(f.Result_1)) = 'L' THEN LTRIM(RTRIM(f.Fighter_2))
        WHEN LTRIM(RTRIM(f.Result_1)) = 'D' THEN 'Draw'
        ELSE 'No Contest'
    END AS Winner,
    CASE 
        WHEN LTRIM(RTRIM(f.Result_1)) = 'W' THEN LTRIM(RTRIM(f.Fighter_2))
        WHEN LTRIM(RTRIM(f.Result_1)) = 'L' THEN LTRIM(RTRIM(f.Fighter_1))
        WHEN LTRIM(RTRIM(f.Result_1)) = 'D' THEN 'Draw'
        ELSE 'No Contest'
    END AS Loser,
    
    -- Method & round info
    f.Method,
    TRY_CAST(NULLIF(f.Round,'') AS INT) AS Round,
    f.Fight_Time,
    f.Referee,
    f.Method_Details,

    -- Fighter 1 stats
    TRY_CAST(NULLIF(f.KD_1,'') AS INT) AS KD_1,
    TRY_CAST(NULLIF(f.STR_1,'') AS INT) AS STR_1,
    TRY_CAST(NULLIF(f.TD_1,'') AS INT) AS TD_1,
    TRY_CAST(NULLIF(f.SUB_1,'') AS INT) AS SUB_1,
    TRY_CAST(NULLIF(f.Ctrl_1,'') AS DECIMAL(10,2)) AS Ctrl_1,
    
    -- Fighter 2 stats
    TRY_CAST(NULLIF(f.KD_2,'') AS INT) AS KD_2,
    TRY_CAST(NULLIF(f.STR_2,'') AS INT) AS STR_2,
    TRY_CAST(NULLIF(f.TD_2,'') AS INT) AS TD_2,
    TRY_CAST(NULLIF(f.SUB_2,'') AS INT) AS SUB_2,
    TRY_CAST(NULLIF(f.Ctrl_2,'') AS DECIMAL(10,2)) AS Ctrl_2,

    CAST(GETDATE() AS DATETIME) AS View_Refreshed_At
FROM silver.Fights f
LEFT JOIN silver.Events e  -- ⬅️ Added JOIN to get event date
    ON f.Event_Id = e.Event_Id;
GO
------------------------------------------------------------


------------------------------------------------------------
-- 6️⃣ Optional: Fact_Event_Metrics
-- Event-level metrics aggregated
------------------------------------------------------------
CREATE OR ALTER VIEW gold.Fact_Event_Metrics
AS
SELECT
    e.Event_Id,
    COUNT(f.Event_Id) AS Total_Fights,
    AVG(TRY_CAST(NULLIF(f.Round,'') AS DECIMAL(5,2))) AS Avg_Rounds_Per_Fight,
    SUM(CASE WHEN f.Method LIKE '%KO%' OR f.Method LIKE '%TKO%' THEN 1 ELSE 0 END) AS Total_Knockouts,
    SUM(CASE WHEN f.Method LIKE '%Submission%' THEN 1 ELSE 0 END) AS Total_Submissions,
    AVG(ISNULL(TRY_CAST(NULLIF(f.KD_1,'') AS INT),0) + ISNULL(TRY_CAST(NULLIF(f.KD_2,'') AS INT),0)) AS Avg_Knockdowns_Per_Fight,
    AVG(ISNULL(TRY_CAST(NULLIF(f.SUB_1,'') AS INT),0) + ISNULL(TRY_CAST(NULLIF(f.SUB_2,'') AS INT),0)) AS Avg_Sub_Attempts_Per_Fight,
    CAST(GETDATE() AS DATETIME) AS View_Refreshed_At
FROM silver.Events e
LEFT JOIN silver.Fights f
    ON e.Event_Id = f.Event_Id
GROUP BY e.Event_Id;
GO

------------------------------------------------------------
-- ✅ Gold Layer Summary
-- Dimensions:
--    Dim_Fighter
--    Dim_Event
--    Dim_WeightClass
--    Dim_Date
--    Dim_Method
-- Facts:
--    Fact_Fight_Performance
--    Fact_Event_Metrics
------------------------------------------------------------
PRINT('🏆 Gold Layer with proper surrogate keys and facts/dims ready for analytics!');
GO
