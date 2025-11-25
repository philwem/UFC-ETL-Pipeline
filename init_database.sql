-- init_database.sql
-- This script initializes the UFC_DataWareHouse database and creates the bronze, silver, and gold schemas.
USE master;  -- Switch to the master database
GO

-- Check if the database already exists and drop it if it does
IF  EXISTS (SELECT * FROM sys.databases WHERE name = 'UFC_DataWareHouse')
BEGIN
    PRINT 'Database UFC_DataWareHouse already exists.';
    ALTER DATABASE UFC_DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE UFC_DataWareHouse;
END ;
GO

-- Create the UFC_DataWareHouse database
CREATE DATABASE UFC_DataWareHouse;
GO
USE UFC_DataWareHouse;  -- Switch to the newly created database
GO
CREATE SCHEMA bronze;   -- Create the bronze schema
GO
CREATE SCHEMA silver;   -- Create the silver schema
GO
CREATE SCHEMA gold;     -- Create the gold schema
GO

PRINT('✅ Bronze, Silver, and Gold schemas created successfully.');



-- ------------------------------------------------------------



-- SELECT COLUMN_NAME 
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_SCHEMA = 'bronze' AND TABLE_NAME = 'Fighter_Stats';















-- check server name--
-- SELECT @@SERVERNAME AS 'Server Name';

-- SELECT * FROM bronze.Events;
-- SELECT * FROM bronze.Fighter_Stats;
-- SELECT * FROM bronze.Fighters;
-- SELECT * FROM bronze.Fights;

-- SELECT * FROM silver.Events;
-- SELECT * FROM silver.Fighter_Stats;
-- SELECT * FROM silver.Fighters;
-- SELECT * FROM silver.Fights;

-- SELECT * FROM gold_views;

-- USE UFC_DataWareHouse;
-- GO

-- PRINT '==============================';
-- PRINT '🔍 BRONZE LAYER VALIDATION CHECK';
-- PRINT '==============================';
-- PRINT '';

-- ------------------------------------------------------------
-- -- 1️⃣ ROW COUNTS VALIDATION
-- ------------------------------------------------------------
-- PRINT '📊 ROW COUNTS';
-- SELECT 
--     'bronze.Events' AS Table_Name, COUNT(*) AS Row_Count FROM bronze.Events
-- UNION ALL
-- SELECT 
--     'bronze.Fighter_Stats', COUNT(*) FROM bronze.Fighter_Stats
-- UNION ALL
-- SELECT 
--     'bronze.Fighters', COUNT(*) FROM bronze.Fighters
-- UNION ALL
-- SELECT 
--     'bronze.Fights', COUNT(*) FROM bronze.Fights;
-- PRINT '';

-- ------------------------------------------------------------
-- -- 2️⃣ SCHEMA VERIFICATION
-- ------------------------------------------------------------
-- PRINT '🧩 TABLE SCHEMA DETAILS';
-- SELECT 
--     TABLE_SCHEMA, 
--     TABLE_NAME, 
--     COLUMN_NAME, 
--     DATA_TYPE, 
--     CHARACTER_MAXIMUM_LENGTH
-- FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_SCHEMA = 'bronze'
-- ORDER BY TABLE_NAME, ORDINAL_POSITION;
-- PRINT '';

-- ------------------------------------------------------------
-- -- 3️⃣ NULL / MISSING VALUES CHECKS
-- ------------------------------------------------------------
-- PRINT '⚠️ MISSING VALUES CHECK';
-- -- Events
-- SELECT 
--     'bronze.Events' AS Table_Name,
--     SUM(CASE WHEN Event_Id IS NULL OR Event_Id = '' THEN 1 ELSE 0 END) AS Missing_Event_Id,
--     SUM(CASE WHEN Name IS NULL OR Name = '' THEN 1 ELSE 0 END) AS Missing_Name,
--     SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS Missing_Date,
--     SUM(CASE WHEN Location IS NULL OR Location = '' THEN 1 ELSE 0 END) AS Missing_Location
-- FROM bronze.Events;

-- -- Fighter_Stats
SELECT 
    'bronze.Fighter_Stats' AS Table_Name,
    SUM(CASE WHEN Fighter_Id IS NULL OR Fighter_Id = '' THEN 1 ELSE 0 END) AS Missing_Fighter_Id,
    SUM(CASE WHEN Full_Name IS NULL OR Full_Name = '' THEN 1 ELSE 0 END) AS Missing_Full_Name,
    SUM(CASE WHEN W IS NULL THEN 1 ELSE 0 END) AS Missing_Wins,
    SUM(CASE WHEN L IS NULL THEN 1 ELSE 0 END) AS Missing_Losses
FROM bronze.Fighter_Stats;

-- -- Fighters
-- SELECT 
--     'bronze.Fighters' AS Table_Name,
--     SUM(CASE WHEN Full_Name IS NULL OR Full_Name = '' THEN 1 ELSE 0 END) AS Missing_Full_Name,
--     SUM(CASE WHEN Ht IS NULL OR Ht = '' THEN 1 ELSE 0 END) AS Missing_Height,
--     SUM(CASE WHEN Wt IS NULL OR Wt = '' THEN 1 ELSE 0 END) AS Missing_Weight,
--     SUM(CASE WHEN Reach IS NULL OR Reach = '' THEN 1 ELSE 0 END) AS Missing_Reach
-- FROM bronze.Fighters;

-- -- Fights
-- SELECT 
--     'bronze.Fights' AS Table_Name,
--     SUM(CASE WHEN Fighter_1 IS NULL OR Fighter_1 = '' THEN 1 ELSE 0 END) AS Missing_Fighter_1,
--     SUM(CASE WHEN Fighter_2 IS NULL OR Fighter_2 = '' THEN 1 ELSE 0 END) AS Missing_Fighter_2,
--     SUM(CASE WHEN Event_Id IS NULL OR Event_Id = '' THEN 1 ELSE 0 END) AS Missing_Event_Id,
--     SUM(CASE WHEN Method IS NULL OR Method = '' THEN 1 ELSE 0 END) AS Missing_Method
-- FROM bronze.Fights;
-- PRINT '';

-- ------------------------------------------------------------
-- -- 4️⃣ NON-NUMERIC VALUE CHECKS (ANOMALIES)
-- ------------------------------------------------------------
-- PRINT '🔢 NON-NUMERIC VALUE CHECKS';
-- -- Example for numeric fields that may contain text
-- SELECT 'bronze.Fighter_Stats' AS Table_Name, 'W' AS Column_Name, COUNT(*) AS Non_Numeric_Values
-- FROM bronze.Fighter_Stats
-- WHERE TRY_CAST(W AS INT) IS NULL AND W IS NOT NULL
-- UNION ALL
-- SELECT 'bronze.Fighter_Stats', 'L', COUNT(*) 
-- FROM bronze.Fighter_Stats
-- WHERE TRY_CAST(L AS INT) IS NULL AND L IS NOT NULL
-- UNION ALL
-- SELECT 'bronze.Fighter_Stats', 'D', COUNT(*) 
-- FROM bronze.Fighter_Stats
-- WHERE TRY_CAST(D AS INT) IS NULL AND D IS NOT NULL
-- UNION ALL
-- SELECT 'bronze.Fights', 'KD_1', COUNT(*) 
-- FROM bronze.Fights
-- WHERE TRY_CAST(KD_1 AS INT) IS NULL AND KD_1 IS NOT NULL;
-- PRINT '';

-- PRINT '✅ VALIDATION COMPLETE';
-- PRINT '==============================';

