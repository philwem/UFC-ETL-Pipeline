
# 📘 **Gold Layer Data Catalog – UFC Analytics Warehouse**

## **Overview**

The **Gold Layer** represents refined, analytics-ready data optimized for BI dashboards, machine learning models, fighter performance analytics, and event-level reporting.

It is modeled using a **star schema**, consisting of **dimension tables** (business entities) and **fact tables** (metrics + foreign keys referencing dimensions).
Surrogate Keys (SKs) ensure consistent, stable linking between facts and dimensions across the UFC dataset.

---

---

# ⭐ **1. gold.Dim_Fighter**

**Purpose:**
Stores master data for UFC fighters, enriched with attributes, physical metrics, and aggregated statistics.

### **Columns**

| Column Name             | Data Type     | Description                                                        |
| ----------------------- | ------------- | ------------------------------------------------------------------ |
| **Fighter_SK**          | INT           | Surrogate key generated from fighter name (stable, deterministic). |
| **Full_Name**           | NVARCHAR(100) | Fighter’s full name.                                               |
| **Nickname**            | NVARCHAR(100) | Fighter's nickname (if available).                                 |
| **Gender**              | NVARCHAR(20)  | Gender of the fighter.                                             |
| **Weight_Class**        | NVARCHAR(50)  | Fighter’s primary weight class.                                    |
| **Fighting_Style**      | NVARCHAR(50)  | Declared fighting style (e.g., striker, wrestler).                 |
| **Height_cm**           | DECIMAL(8,2)  | Height in centimeters.                                             |
| **Weight_kg**           | DECIMAL(8,2)  | Weight in kilograms.                                               |
| **Reach_cm**            | DECIMAL(8,2)  | Arm reach in centimeters.                                          |
| **Stance**              | NVARCHAR(50)  | Fighting stance (e.g., Orthodox, Southpaw).                        |
| **W**                   | INT           | Total wins.                                                        |
| **L**                   | INT           | Total losses.                                                      |
| **D**                   | INT           | Total draws.                                                       |
| **Win_Rate**            | DECIMAL(5,2)  | Percentage of fights won.                                          |
| **Sig_Str_Accuracy**    | DECIMAL(8,2)  | Strike accuracy percentage.                                        |
| **Takedown_Accuracy**   | DECIMAL(8,2)  | Takedown rate percentage.                                          |
| **Submission_Attempts** | DECIMAL(5,2)  | Avg submissions attempted.                                         |
| **Reversals**           | DECIMAL(5,2)  | Avg reversals per fight.                                           |
| **View_Refreshed_At**   | DATETIME      | Timestamp when the dimension was last refreshed.                   |

---

---

# ⭐ **2. gold.Dim_Event**

**Purpose:**
Contains event-level metadata for UFC events.

### **Columns**

| Column Name       | Data Type     | Description                        |
| ----------------- | ------------- | ---------------------------------- |
| **Event_Id**      | INT           | Natural event ID from UFC dataset. |
| **Event_Name**    | NVARCHAR(150) | Name of the event (e.g., UFC 300). |
| **Event_Date**    | DATE          | Date of the event.                 |
| **Location**      | NVARCHAR(100) | Event location (city, arena).      |
| **Event_Month**   | NVARCHAR(20)  | Month name of the event.           |
| **Event_Year**    | INT           | Year of the event.                 |
| **Event_Quarter** | INT           | Quarter of the year (1–4).         |

---

---

# ⭐ **3. gold.Dim_WeightClass**

**Purpose:**
Reference table for UFC weight classes with aggregated fight counts.

### **Columns**

| Column Name           | Data Type    | Description                                     |
| --------------------- | ------------ | ----------------------------------------------- |
| **Weight_Class**      | NVARCHAR(50) | Weight class name (e.g., Featherweight).        |
| **Total_Fights**      | INT          | Count of fights occurring in this weight class. |
| **View_Refreshed_At** | DATETIME     | Last refresh timestamp.                         |

---

---

# ⭐ **4. gold.Dim_Method**

**Purpose:**
Contains all unique fight-ending methods with surrogate keys.

### **Columns**

| Column Name           | Data Type     | Description                                             |
| --------------------- | ------------- | ------------------------------------------------------- |
| **Method_SK**         | INT           | Surrogate key for method type (e.g., KO, TKO).          |
| **Method**            | NVARCHAR(100) | Primary fight-ending method.                            |
| **Method_Details**    | NVARCHAR(150) | Detailed method description (e.g., "Rear Naked Choke"). |
| **View_Refreshed_At** | DATETIME      | Refresh timestamp.                                      |

---

---

# ⭐ **5. gold.Dim_Date**

**Purpose:**
Calendar dimension used for time-series reporting.

### **Columns**

| Column Name           | Data Type    | Description                          |
| --------------------- | ------------ | ------------------------------------ |
| **Date_SK**           | DATE         | Surrogate date key (stored as date). |
| **Year**              | INT          | Calendar year.                       |
| **Month_Name**        | NVARCHAR(20) | Full month name.                     |
| **Month**             | INT          | Month number (1–12).                 |
| **Day**               | INT          | Day of month.                        |
| **Quarter**           | INT          | Year quarter.                        |
| **Weekday_Name**      | NVARCHAR(20) | Name of the weekday.                 |
| **View_Refreshed_At** | DATETIME     | Refresh timestamp.                   |

---

---

# ⭐ **6. gold.Fact_Fight_Performance**

**Purpose:**
Stores detailed fight-level performance metrics for each bout.
This is the **core fact table** supporting fighter comparisons, analytics dashboards, ML models, and historical trends.

### **Columns**

| Column Name      | Data Type    | Description                               |
| ---------------- | ------------ | ----------------------------------------- |
| **Method_SK**    | INT          | FK → Dim_Method.                          |
| **Date_SK**      | DATE         | FK → Dim_Date.                            |
| **Fighter_1_SK** | INT          | FK → Dim_Fighter.                         |
| **Fighter_2_SK** | INT          | FK → Dim_Fighter.                         |
| **Event_SK**     | INT          | FK → Dim_Event.                           |
| **Weight_Class** | NVARCHAR(50) | Reference to weight class (joins to dim). |

### **Fight Results**

| Column             | Data Type     | Description              |
| ------------------ | ------------- | ------------------------ |
| **Result_1**       | NVARCHAR(5)   | W/L/D for fighter 1.     |
| **Result_2**       | NVARCHAR(5)   | W/L/D for fighter 2.     |
| **Winner**         | NVARCHAR(100) | Name of winning fighter. |
| **Loser**          | NVARCHAR(100) | Name of losing fighter.  |
| **Method**         | NVARCHAR(100) | Method of victory.       |
| **Round**          | INT           | Round ended.             |
| **Fight_Time**     | NVARCHAR(50)  | Duration of fight.       |
| **Referee**        | NVARCHAR(100) | Referee for the bout.    |
| **Method_Details** | NVARCHAR(150) | Expanded method details. |

### **Fighter 1 Stats**

| Column     | Data Type     | Description          |
| ---------- | ------------- | -------------------- |
| **KD_1**   | INT           | Knockdowns.          |
| **STR_1**  | INT           | Significant strikes. |
| **TD_1**   | INT           | Takedowns.           |
| **SUB_1**  | INT           | Submission attempts. |
| **Ctrl_1** | DECIMAL(10,2) | Control time.        |

### **Fighter 2 Stats**

| Column     | Data Type     | Description          |
| ---------- | ------------- | -------------------- |
| **KD_2**   | INT           | Knockdowns.          |
| **STR_2**  | INT           | Significant strikes. |
| **TD_2**   | INT           | Takedowns.           |
| **SUB_2**  | INT           | Submission attempts. |
| **Ctrl_2** | DECIMAL(10,2) | Control time.        |

### Metadata

| Column                | Data Type | Description           |
| --------------------- | --------- | --------------------- |
| **View_Refreshed_At** | DATETIME  | Timestamp of refresh. |

---

---

# ⭐ **7. gold.Fact_Event_Metrics**

**Purpose:**
Aggregated event-level metrics for dashboards and reporting.

### **Columns**

| Column Name                    | Data Type    | Description                |
| ------------------------------ | ------------ | -------------------------- |
| **Event_Id**                   | INT          | FK → Dim_Event.            |
| **Total_Fights**               | INT          | Total fights at event.     |
| **Avg_Rounds_Per_Fight**       | DECIMAL(5,2) | Average number of rounds.  |
| **Total_Knockouts**            | INT          | Total KOs/TKOs.            |
| **Total_Submissions**          | INT          | Total submission finishes. |
| **Avg_Knockdowns_Per_Fight**   | DECIMAL(5,2) | Avg knockdowns.            |
| **Avg_Sub_Attempts_Per_Fight** | DECIMAL(5,2) | Avg submission attempts.   |
| **View_Refreshed_At**          | DATETIME     | Refresh timestamp.         |

---

---

# 🎉 **Gold Layer Summary**

| Category       | Tables                                                        |
| -------------- | ------------------------------------------------------------- |
| **Dimensions** | Dim_Fighter, Dim_Event, Dim_WeightClass, Dim_Date, Dim_Method |
| **Facts**      | Fact_Fight_Performance, Fact_Event_Metrics                    |

✔ Fully supports star schema
✔ Ready for Power BI, Tableau, ML models
✔ Uses surrogate keys for stability and consistency

---



