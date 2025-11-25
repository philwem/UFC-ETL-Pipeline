
CREATE OR ALTER PROCEDURE usp_load_silver
AS
BEGIN
    SET NOCOUNT ON;

    ----------------------------------------------------------------
    PRINT('================= 🥈 STARTING SILVER LOAD =================');

    ----------------------------------------------------------------
    -- 1️⃣ Events
    ----------------------------------------------------------------
    TRUNCATE TABLE silver.Events;
    INSERT INTO silver.Events (Event_Id, Name, Date, Location)
    SELECT DISTINCT
        LTRIM(RTRIM(Event_Id)),
        LTRIM(RTRIM(Name)),
        TRY_CONVERT(DATE, NULLIF(LTRIM(RTRIM(Date)), '')) AS Event_Date,
        LTRIM(RTRIM(Location))
    FROM bronze.Events
    WHERE NULLIF(LTRIM(RTRIM(Event_Id)), '') IS NOT NULL
      AND NULLIF(LTRIM(RTRIM(Name)), '') IS NOT NULL;

    PRINT('✅ Loaded cleaned Events → silver.Events');


    -----------------------------------------------------------------
    -- 2️⃣ Fighters
    -----------------------------------------------------------------
    TRUNCATE TABLE silver.Fighters;
    INSERT INTO silver.Fighters (Full_Name, Nickname, Ht, Wt, Reach, Stance, W, L, D, Belt)
    SELECT DISTINCT
        LTRIM(RTRIM(Full_Name)),
        NULLIF(LTRIM(RTRIM(Nickname)), ''),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Ht)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Wt)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Reach)), '')),
        LTRIM(RTRIM(Stance)),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(W)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(L)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(D)), '')),
        LTRIM(RTRIM(Belt))
    FROM bronze.Fighters
    WHERE NULLIF(LTRIM(RTRIM(Full_Name)), '') IS NOT NULL;

    PRINT('✅ Loaded cleaned Fighters → silver.Fighters');


    -----------------------------------------------------------------
    -- 3️⃣ Fighter_Stats
    -----------------------------------------------------------------
    TRUNCATE TABLE silver.Fighter_Stats;
    INSERT INTO silver.Fighter_Stats (
        Fighter_Id, Full_Name, Nickname, Ht, Wt, Stance, W, L, D, Belt, Round,
        KD, STR, TD, SUB, Ctrl, Sig_Str_Percent, Head_Percent, Body_Percent,
        Leg_Percent, Distance_Percent, Clinch_Percent, Ground_Percent,
        Sub_Att, Rev, Weight_Class, Gender, Fighting_Style
    )
    SELECT DISTINCT
        LTRIM(RTRIM(Fighter_Id)),
        LTRIM(RTRIM(Full_Name)),
        NULLIF(LTRIM(RTRIM(Nickname)), ''),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Ht)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Wt)), '')),
        LTRIM(RTRIM(Stance)),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(W)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(L)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(D)), '')),
        LTRIM(RTRIM(Belt)),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Round)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(KD)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(STR)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(TD)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(SUB)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Ctrl)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Sig_Str_Percent)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Head_Percent)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Body_Percent)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Leg_Percent)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Distance_Percent)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Clinch_Percent)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Ground_Percent)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Sub_Att)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Rev)), '')),
        LTRIM(RTRIM(Weight_Class)),
        LTRIM(RTRIM(Gender)),
        LTRIM(RTRIM(Fighting_Style))
    FROM bronze.Fighter_Stats
    WHERE NULLIF(LTRIM(RTRIM(Fighter_Id)), '') IS NOT NULL;

    PRINT('✅ Loaded cleaned Fighter_Stats → silver.Fighter_Stats');


    -----------------------------------------------------------------
    -- 4️⃣ Fights
    -----------------------------------------------------------------
    TRUNCATE TABLE silver.Fights;
    INSERT INTO silver.Fights (
        Fighter_1, Fighter_2, KD_1, KD_2, STR_1, STR_2, TD_1, TD_2, SUB_1, SUB_2,
        Weight_Class, Method, Round, Fight_Time, Event_Id, Result_1, Result_2,
        Time_Format, Referee, Method_Details,
        Sig_Str_Percent_1, Sig_Str_Percent_2, Sub_Att_1, Sub_Att_2, Rev_1, Rev_2,
        Ctrl_1, Ctrl_2, Head_Percent_1, Head_Percent_2, Body_Percent_1, Body_Percent_2,
        Leg_Percent_1, Leg_Percent_2, Distance_Percent_1, Distance_Percent_2,
        Clinch_Percent_1, Clinch_Percent_2, Ground_Percent_1, Ground_Percent_2,
        Total_Str_Percent_1, Total_Str_Percent_2
    )
    SELECT DISTINCT
        LTRIM(RTRIM(Fighter_1)),
        LTRIM(RTRIM(Fighter_2)),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(KD_1)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(KD_2)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(STR_1)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(STR_2)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(TD_1)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(TD_2)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(SUB_1)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(SUB_2)), '')),
        LTRIM(RTRIM(Weight_Class)),
        LTRIM(RTRIM(Method)),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Round)), '')),
        LTRIM(RTRIM(Fight_Time)),
        LTRIM(RTRIM(Event_Id)),
        LTRIM(RTRIM(Result_1)),
        LTRIM(RTRIM(Result_2)),
        LTRIM(RTRIM(Time_Format)),
        LTRIM(RTRIM(Referee)),
        LTRIM(RTRIM(Method_Details)),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Sig_Str_Percent_1)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Sig_Str_Percent_2)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Sub_Att_1)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Sub_Att_2)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Rev_1)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Rev_2)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Ctrl_1)), '')),
        TRY_CONVERT(INT, NULLIF(LTRIM(RTRIM(Ctrl_2)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Head_Percent_1)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Head_Percent_2)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Body_Percent_1)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Body_Percent_2)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Leg_Percent_1)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Leg_Percent_2)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Distance_Percent_1)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Distance_Percent_2)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Clinch_Percent_1)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Clinch_Percent_2)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Ground_Percent_1)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Ground_Percent_2)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Total_Str_Percent_1)), '')),
        TRY_CONVERT(DECIMAL(5,2), NULLIF(LTRIM(RTRIM(Total_Str_Percent_2)), ''))
    FROM bronze.Fights
    WHERE NULLIF(LTRIM(RTRIM(Event_Id)), '') IS NOT NULL;

    PRINT('✅ Loaded cleaned Fights → silver.Fights');


    -----------------------------------------------------------------
    -- ✅ VALIDATION SECTION
    -----------------------------------------------------------------
    PRINT('================= 🔍 VALIDATION SUMMARY =================');

    DECLARE @EventCount INT = (SELECT COUNT(*) FROM silver.Events);
    DECLARE @FighterCount INT = (SELECT COUNT(*) FROM silver.Fighters);
    DECLARE @FighterStatsCount INT = (SELECT COUNT(*) FROM silver.Fighter_Stats);
    DECLARE @FightCount INT = (SELECT COUNT(*) FROM silver.Fights);

    PRINT('📊 silver.Events: ' + CAST(@EventCount AS VARCHAR(10)) + ' records');
    PRINT('📊 silver.Fighters: ' + CAST(@FighterCount AS VARCHAR(10)) + ' records');
    PRINT('📊 silver.Fighter_Stats: ' + CAST(@FighterStatsCount AS VARCHAR(10)) + ' records');
    PRINT('📊 silver.Fights: ' + CAST(@FightCount AS VARCHAR(10)) + ' records');

    PRINT('==========================================================');
    PRINT('✅ SILVER LOAD COMPLETE');
END;
GO

-- 🏁 Run the ETL
EXEC usp_load_silver;
