/* ============================================================================
   init_database.sql
   Purpose  : Initialize the UFC Data Warehouse using Medallion Architecture
   Layers   : bronze, silver, gold
   Author   : Philip Mawuli Wemegah
   ============================================================================
*/

-- -- Drop and recreate database (development use only)
-- IF EXISTS (SELECT * FROM sys.databases WHERE name = 'UFC-WareHouse')
-- BEGIN
--     ALTER DATABASE [UFC-WareHouse] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--     DROP DATABASE [UFC-WareHouse];
-- END;
-- GO

-- -- Create database
-- CREATE DATABASE [UFC-DataWareHouse];
-- GO

USE [UFC-DataWareHouse];
GO

/* ============================================================================
   Create Schemas
============================================================================ */
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
    EXEC ('CREATE SCHEMA bronze');

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
    EXEC ('CREATE SCHEMA silver');

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
    EXEC ('CREATE SCHEMA gold');

PRINT 'Schemas bronze, silver, and gold created successfully.';
GO

/* ============================================================================
   Minimal Bronze Layer Validation (Optional but Recommended)
   These checks ensure the raw data loaded correctly.
============================================================================ */

-- Row Count Check
SELECT 
    'bronze.Events' AS Table_Name, COUNT(*) AS Row_Count FROM bronze.Events
UNION ALL
SELECT 'bronze.Fighter_Stats', COUNT(*) FROM bronze.Fighter_Stats
UNION ALL
SELECT 'bronze.Fighters', COUNT(*) FROM bronze.Fighters
UNION ALL
SELECT 'bronze.Fights', COUNT(*) FROM bronze.Fights;

-- Basic Null Check on Critical IDs
SELECT 
    'bronze.Events' AS Table_Name,
    SUM(CASE WHEN Event_Id IS NULL OR Event_Id = '' THEN 1 ELSE 0 END) AS Missing_Event_Id
FROM bronze.Events;

SELECT 
    'bronze.Fighter_Stats' AS Table_Name,
    SUM(CASE WHEN Fighter_Id IS NULL OR Fighter_Id = '' THEN 1 ELSE 0 END) AS Missing_Fighter_Id
FROM bronze.Fighter_Stats;

SELECT 
    'bronze.Fights' AS Table_Name,
    SUM(CASE WHEN Event_Id IS NULL OR Event_Id = '' THEN 1 ELSE 0 END) AS Missing_Event_Id
FROM bronze.Fights;

PRINT 'Basic Bronze validation completed.';
GO
