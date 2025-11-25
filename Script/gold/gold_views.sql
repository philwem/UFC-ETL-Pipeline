------------------------------------------------------------
-- 1️⃣ Schema Setup (Gold Layer)
------------------------------------------------------------
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

------------------------------------------------------------
-- 2️⃣ vw_Dim_Fighter
-- Clean dimension of fighters with key stats & attributes
------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_Dim_Fighter
AS
SELECT
    ROW_NUMBER() OVER (ORDER BY f.Full_Name) AS Fighter_SK,
    f.Full_Name,
    f.Nickname,
    s.Gender,
    s.Weight_Class,
    s.Fighting_Style,
    f.Ht AS Height_cm,
    f.Wt AS Weight_kg,
    f.Reach AS Reach_cm,
    f.Stance,
    s.W,
    s.L,
    s.D,
    CASE 
        WHEN (s.W + s.L) > 0 
        THEN CAST((s.W * 100.0) / (s.W + s.L) AS DECIMAL(5,2))
        ELSE 0 
    END AS Win_Rate,
    TRY_CAST(s.Sig_Str_Percent AS DECIMAL(5,2)) AS Sig_Str_Accuracy,
    TRY_CAST(s.TD AS DECIMAL(5,2)) AS Takedown_Accuracy,
    TRY_CAST(s.Sub_Att AS DECIMAL(5,2)) AS Submission_Attempts,
    TRY_CAST(s.Rev AS DECIMAL(5,2)) AS Reversals,
    CAST(GETDATE() AS DATE) AS View_Refreshed_At
FROM silver.Fighters f
LEFT JOIN silver.Fighter_Stats s
    ON f.Full_Name = s.Full_Name;
GO

------------------------------------------------------------
-- 3️⃣ vw_Dim_Event
-- Event-level details and date breakdown
------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_Dim_Event
AS
SELECT
    Event_Id,
    Name AS Event_Name,
    Date AS Event_Date,
    Location,
    DATENAME(MONTH, Date) AS Event_Month,
    YEAR(Date) AS Event_Year,
    DATEPART(QUARTER, Date) AS Event_Quarter
FROM silver.Events;
GO

------------------------------------------------------------
-- 4️⃣ vw_Fact_Fight_Performance
-- Fight-level facts joined with events
------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_Fact_Fight_Performance
AS
SELECT
    f.Event_Id,
    e.Name AS Event_Name,
    e.Date AS Event_Date,
    f.Fighter_1,
    f.Fighter_2,
    f.Result_1,
    f.Result_2,
    CASE 
        WHEN f.Result_1 = 'W' THEN f.Fighter_1
        WHEN f.Result_1 = 'L' THEN f.Fighter_2
        WHEN f.Result_1 = 'D' THEN 'Draw'
        ELSE 'No Contest'
    END AS Winner,
    CASE 
        WHEN f.Result_1 = 'W' THEN f.Fighter_2
        WHEN f.Result_1 = 'L' THEN f.Fighter_1
        WHEN f.Result_1 = 'D' THEN 'Draw'
        ELSE 'No Contest'
    END AS Loser,
    f.Method,
    f.Round,
    f.Fight_Time,
    f.Weight_Class,
    f.Referee,
    f.Method_Details,
    
    -- Fighter 1 Stats (converted to numeric)
    TRY_CAST(f.KD_1 AS INT) AS KD_1,
    TRY_CAST(f.STR_1 AS INT) AS STR_1,
    TRY_CAST(f.TD_1 AS INT) AS TD_1,
    TRY_CAST(f.SUB_1 AS INT) AS SUB_1,
    TRY_CAST(f.Ctrl_1 AS DECIMAL(10,2)) AS Ctrl_1,
    TRY_CAST(f.Head_Percent_1 AS DECIMAL(5,2)) AS Head_Percent_1,
    TRY_CAST(f.Body_Percent_1 AS DECIMAL(5,2)) AS Body_Percent_1,
    TRY_CAST(f.Distance_Percent_1 AS DECIMAL(5,2)) AS Distance_Percent_1,
    TRY_CAST(f.Clinch_Percent_1 AS DECIMAL(5,2)) AS Clinch_Percent_1,
    TRY_CAST(f.Ground_Percent_1 AS DECIMAL(5,2)) AS Ground_Percent_1,
    
    -- Fighter 2 Stats (converted to numeric)
    TRY_CAST(f.KD_2 AS INT) AS KD_2,
    TRY_CAST(f.STR_2 AS INT) AS STR_2,
    TRY_CAST(f.TD_2 AS INT) AS TD_2,
    TRY_CAST(f.SUB_2 AS INT) AS SUB_2,
    TRY_CAST(f.Ctrl_2 AS DECIMAL(10,2)) AS Ctrl_2,
    TRY_CAST(f.Head_Percent_2 AS DECIMAL(5,2)) AS Head_Percent_2,
    TRY_CAST(f.Body_Percent_2 AS DECIMAL(5,2)) AS Body_Percent_2,
    TRY_CAST(f.Distance_Percent_2 AS DECIMAL(5,2)) AS Distance_Percent_2,
    TRY_CAST(f.Clinch_Percent_2 AS DECIMAL(5,2)) AS Clinch_Percent_2,
    TRY_CAST(f.Ground_Percent_2 AS DECIMAL(5,2)) AS Ground_Percent_2,
    
    CAST(GETDATE() AS DATE) AS View_Refreshed_At
FROM silver.Fights f
LEFT JOIN silver.Events e
    ON f.Event_Id = e.Event_Id;
GO

------------------------------------------------------------
-- 5️⃣ vw_Fighter_Performance_Summary
-- Aggregated fighter-level performance summary
------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_Fighter_Performance_Summary
AS
WITH FighterResults AS (
    -- Get all fights for Fighter_1
    SELECT 
        Fighter_1 AS Fighter_Name,
        CASE WHEN Result_1 = 'W' THEN 1 ELSE 0 END AS Win,
        CASE WHEN Result_1 = 'L' THEN 1 ELSE 0 END AS Loss,
        CASE WHEN Result_1 = 'D' THEN 1 ELSE 0 END AS Draw,
        Event_Id
    FROM silver.Fights
    WHERE Fighter_1 IS NOT NULL
    
    UNION ALL
    
    -- Get all fights for Fighter_2
    SELECT 
        Fighter_2 AS Fighter_Name,
        CASE WHEN Result_2 = 'W' THEN 1 ELSE 0 END AS Win,
        CASE WHEN Result_2 = 'L' THEN 1 ELSE 0 END AS Loss,
        CASE WHEN Result_2 = 'D' THEN 1 ELSE 0 END AS Draw,
        Event_Id
    FROM silver.Fights
    WHERE Fighter_2 IS NOT NULL
)
SELECT
    fs.Full_Name,
    COUNT(DISTINCT fr.Event_Id) AS Total_Fights,
    SUM(fr.Win) AS Wins,
    SUM(fr.Loss) AS Losses,
    SUM(fr.Draw) AS Draws,
    CASE 
        WHEN SUM(fr.Win) + SUM(fr.Loss) > 0 
        THEN CAST((SUM(fr.Win) * 100.0) / (SUM(fr.Win) + SUM(fr.Loss)) AS DECIMAL(5,2))
        ELSE 0 
    END AS Win_Percentage,
    
    -- Convert text to numeric before averaging
    AVG(TRY_CAST(fs.Sig_Str_Percent AS DECIMAL(5,2))) AS Avg_Sig_Str_Accuracy,
    AVG(TRY_CAST(fs.TD AS DECIMAL(5,2))) AS Avg_Takedown_Accuracy,
    AVG(TRY_CAST(fs.Ctrl AS DECIMAL(10,2))) AS Avg_Control_Time,
    AVG(TRY_CAST(fs.Sub_Att AS DECIMAL(5,2))) AS Avg_Sub_Attempts
    
FROM silver.Fighter_Stats fs
LEFT JOIN FighterResults fr 
    ON fs.Full_Name = fr.Fighter_Name
GROUP BY fs.Full_Name;
GO

------------------------------------------------------------
-- 6️⃣ vw_Fight_Method_Analysis
-- Analysis of fight outcomes by method
------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_Fight_Method_Analysis
AS
SELECT
    Method,
    Method_Details,
    Weight_Class,
    COUNT(*) AS Total_Fights,
    AVG(CAST(Round AS DECIMAL(5,2))) AS Avg_Round_Ended,
    MIN(Round) AS Earliest_Round,
    MAX(Round) AS Latest_Round
FROM silver.Fights
WHERE Method IS NOT NULL
GROUP BY Method, Method_Details, Weight_Class;
GO

------------------------------------------------------------
-- 7️⃣ vw_Weight_Class_Statistics
-- Aggregated statistics by weight class
------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_Weight_Class_Statistics
AS
SELECT
    Weight_Class,
    COUNT(DISTINCT Event_Id) AS Total_Events,
    COUNT(*) AS Total_Fights,
    AVG(TRY_CAST(Round AS DECIMAL(5,2))) AS Avg_Rounds,
    SUM(CASE WHEN Method LIKE '%KO%' OR Method LIKE '%TKO%' THEN 1 ELSE 0 END) AS KO_TKO_Finishes,
    SUM(CASE WHEN Method LIKE '%Submission%' THEN 1 ELSE 0 END) AS Submission_Finishes,
    SUM(CASE WHEN Method LIKE '%Decision%' THEN 1 ELSE 0 END) AS Decision_Finishes,
    CAST(
        (SUM(CASE WHEN Method LIKE '%KO%' OR Method LIKE '%TKO%' THEN 1 ELSE 0 END) * 100.0) / 
        NULLIF(COUNT(*), 0) AS DECIMAL(5,2)
    ) AS KO_Rate,
    CAST(
        (SUM(CASE WHEN Method LIKE '%Submission%' THEN 1 ELSE 0 END) * 100.0) / 
        NULLIF(COUNT(*), 0) AS DECIMAL(5,2)
    ) AS Submission_Rate
FROM silver.Fights
WHERE Weight_Class IS NOT NULL
GROUP BY Weight_Class;
GO

------------------------------------------------------------
-- 8️⃣ vw_Event_Performance_Metrics
-- Event-level aggregated metrics
------------------------------------------------------------
CREATE OR ALTER VIEW gold.vw_Event_Performance_Metrics
AS
SELECT
    e.Event_Id,
    e.Name AS Event_Name,
    e.Date AS Event_Date,
    e.Location,
    COUNT(f.Event_Id) AS Total_Fights,
    AVG(TRY_CAST(f.Round AS DECIMAL(5,2))) AS Avg_Rounds_Per_Fight,
    SUM(CASE WHEN f.Method LIKE '%KO%' OR f.Method LIKE '%TKO%' THEN 1 ELSE 0 END) AS Total_Knockouts,
    SUM(CASE WHEN f.Method LIKE '%Submission%' THEN 1 ELSE 0 END) AS Total_Submissions,
    AVG(TRY_CAST(f.KD_1 AS INT) + TRY_CAST(f.KD_2 AS INT)) AS Avg_Knockdowns_Per_Fight,
    AVG(TRY_CAST(f.SUB_1 AS INT) + TRY_CAST(f.SUB_2 AS INT)) AS Avg_Sub_Attempts_Per_Fight
FROM silver.Events e
LEFT JOIN silver.Fights f
    ON e.Event_Id = f.Event_Id
GROUP BY e.Event_Id, e.Name, e.Date, e.Location;
GO

------------------------------------------------------------
-- ✅ Summary
--  Created:
--    gold.vw_Dim_Fighter (with surrogate key & numeric conversions)
--    gold.vw_Dim_Event (with quarter added)
--    gold.vw_Fact_Fight_Performance (with all numeric conversions)
--    gold.vw_Fighter_Performance_Summary (FIXED with proper joins & conversions)
--    gold.vw_Fight_Method_Analysis (BONUS)
--    gold.vw_Weight_Class_Statistics (BONUS)
--    gold.vw_Event_Performance_Metrics (BONUS)
------------------------------------------------------------
PRINT('🏆 All Gold Layer views successfully created!');
GO