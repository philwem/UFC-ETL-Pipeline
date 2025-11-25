   -- DDL for Bronze Layer-
   -- script description: This script creates the necessary tables in the bronze layer of the data warehouse.
   -- Tables: Events, Fighter_Stats, Fighter, Fights

  USE UFC_DataWareHouse;


-- Drop & recreate schema bronze if needed
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');

-- =====================
-- Events Table
-- =====================
IF OBJECT_ID('bronze.Events', 'U') IS NOT NULL
    DROP TABLE bronze.Events;
CREATE TABLE bronze.Events(
    Event_Id NVARCHAR(50),
    Name NVARCHAR(200),
    Date NVARCHAR(50),        -- keep raw text, not DATETIME
    Location NVARCHAR(200)
);

-- =====================
-- Fighter Stats Table
-- =====================
IF OBJECT_ID('bronze.Fighter_Stats', 'U') IS NOT NULL
    DROP TABLE bronze.Fighter_Stats;
CREATE TABLE bronze.Fighter_Stats (
    Fighter_Id NVARCHAR(50),
    Full_Name NVARCHAR(150),
    Nickname NVARCHAR(150),
    Ht NVARCHAR(50),
    Wt NVARCHAR(50),
    Stance NVARCHAR(50),
    W NVARCHAR(10),
    L NVARCHAR(10),
    D NVARCHAR(10),
    Belt NVARCHAR(50),
    Round NVARCHAR(10),
    KD NVARCHAR(10),
    STR NVARCHAR(50),
    TD NVARCHAR(50),
    SUB NVARCHAR(50),
    Ctrl NVARCHAR(50),
    Sig_Str_Percent NVARCHAR(50),
    Head_Percent NVARCHAR(50),
    Body_Percent NVARCHAR(50),
    Leg_Percent NVARCHAR(50),
    Distance_Percent NVARCHAR(50),
    Clinch_Percent NVARCHAR(50),
    Ground_Percent NVARCHAR(50),
    Sub_Att NVARCHAR(10),
    Rev NVARCHAR(10),
    Weight_Class NVARCHAR(50),
    Gender NVARCHAR(20),
    Fighting_Style NVARCHAR(100)
);

-- =====================
-- Fighters Table
-- =====================
IF OBJECT_ID('bronze.Fighters', 'U') IS NOT NULL
    DROP TABLE bronze.Fighters;
CREATE TABLE bronze.Fighters (
    Full_Name NVARCHAR(150),
    Nickname NVARCHAR(100),
    Ht NVARCHAR(50),
    Wt NVARCHAR(50),
    Reach NVARCHAR(50),
    Stance NVARCHAR(50),
    W NVARCHAR(10),
    L NVARCHAR(10),
    D NVARCHAR(10),
    Belt NVARCHAR(50)
);

-- =====================
-- Fights Table
-- =====================
IF OBJECT_ID('bronze.Fights', 'U') IS NOT NULL
    DROP TABLE bronze.Fights;
CREATE TABLE bronze.Fights(
    Fighter_1 NVARCHAR(150),
    Fighter_2 NVARCHAR(150),
    KD_1 NVARCHAR(10),
    KD_2 NVARCHAR(10),
    STR_1 NVARCHAR(50),
    STR_2 NVARCHAR(50),
    TD_1 NVARCHAR(10),
    TD_2 NVARCHAR(10),
    SUB_1 NVARCHAR(10),
    SUB_2 NVARCHAR(10),
    Weight_Class NVARCHAR(50),
    Method NVARCHAR(100),
    Round NVARCHAR(10),
    Fight_Time NVARCHAR(50),   -- keep as string
    Event_Id NVARCHAR(50),
    Result_1 NVARCHAR(50),
    Result_2 NVARCHAR(50),
    Time_Format NVARCHAR(50),
    Referee NVARCHAR(100),
    Method_Details NVARCHAR(200),

    -- Striking / Grappling stats as text
    Sig_Str_Percent_1 NVARCHAR(50),
    Sig_Str_Percent_2 NVARCHAR(50),
    Sub_Att_1 NVARCHAR(10),
    Sub_Att_2 NVARCHAR(10),
    Rev_1 NVARCHAR(10),
    Rev_2 NVARCHAR(10),
    Ctrl_1 NVARCHAR(50),
    Ctrl_2 NVARCHAR(50),
    Head_Percent_1 NVARCHAR(50),
    Head_Percent_2 NVARCHAR(50),
    Body_Percent_1 NVARCHAR(50),
    Body_Percent_2 NVARCHAR(50),
    Leg_Percent_1 NVARCHAR(50),
    Leg_Percent_2 NVARCHAR(50),
    Distance_Percent_1 NVARCHAR(50),
    Distance_Percent_2 NVARCHAR(50),
    Clinch_Percent_1 NVARCHAR(50),
    Clinch_Percent_2 NVARCHAR(50),
    Ground_Percent_1 NVARCHAR(50),
    Ground_Percent_2 NVARCHAR(50),
    Total_Str_Percent_1 NVARCHAR(50),
    Total_Str_Percent_2 NVARCHAR(50),
    Sig_Str_Percent_11 NVARCHAR(100), -- to avoid duplicate column name error
    Sig_Str_Percent_21 NVARCHAR(100) -- to avoid duplicate column name error
);
