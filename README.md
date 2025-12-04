
# 🥋 UFC Data Warehouse & Analytics

A Modern Medallion Architecture (Bronze → Silver → Gold) for UFC Fight, Fighter, and Event Analytics
*Built with SQL Server · Python · ETL Pipelines · Star Schema · BI & Analytics*

---
---

![Python](https://img.shields.io/badge/Python-3.10+-blue.svg)
![SQL Server](https://img.shields.io/badge/SQL%20Server-2019+-red.svg)
![VS Code](https://img.shields.io/badge/Editor-VS%20Code-purple.svg)
![Status](https://img.shields.io/badge/Status-Portfolio%20Project-green.svg)

---

## 📌 **Overview**

This project demonstrates a complete **data engineering + data analytics** solution using real-world style UFC datasets.
It implements a modern **Medallion Architecture (Bronze → Silver → Gold)**, a **Kimball Star Schema**, and a set of **analytical queries and KPIs** for fighter and event performance.

This repository is structured as a full **portfolio project**, showcasing industry best practices:

* Data ingestion & cleansing
* Data modeling (Star Schema)
* Surrogate key generation
* Dimensional modeling (Facts & Dimensions)
* SQL Server ETL + transformation logic
* Analytics queries + insights
* Complete documentation

---

# 🏛 **Project Requirements**

## 🎯 **Objective**

Design and implement a **star schema data warehouse in SQL Server** that consolidates:

* UFC Events
* Fighters
* Fight Results
* Fighter Statistics

The warehouse enables analytics such as fighter performance trends, ranking comparisons, event summaries, and method-of-finish insights.

---

## 📂 **Source Data (CSVs)**

| File                  | Description                            |
| --------------------- | -------------------------------------- |
| **events.csv**        | Event metadata (date, location, name)  |
| **fighters.csv**      | Fighter profiles + physical attributes |
| **fighter_stats.csv** | Per-fighter aggregated statistics      |
| **fights.csv**        | Fight outcomes + round/method stats    |

---

## 🧹 **Data Quality**

Tasks include:

✔ Remove duplicates
✔ Standardize inconsistent formats
✔ Parse textual stats to numeric types
✔ Clean height/weight/reach formats
✔ Harmonize naming differences between datasets

---

## 🔗 **Integration Requirements**

* Merge all datasets into a unified analytical model
* Implement surrogate keys (SKs) for all dimensions
* Build a consistent grain across facts
* Deliver a clean, user-friendly Gold Layer

---

## 📘 **Documentation Requirements**

* ERD (Star Schema Diagram)
* Data Dictionary / Data Catalog
* Transformation logic
* Analytics queries

---

# 🏗️ **Warehouse Architecture (Medallion Model)**

```
Bronze → Raw ingestion (CSV → SQL)
Silver → Standardized, cleaned tables
Gold   → Star schema for analytics (Fact + Dim)
```

---

# ⭐ **Gold Layer (Star Schema)**

This is the final analytical model.
It uses **Kimball-style dimensional modeling** with **Facts** and **Dimensions**.

---

## 🧩 **Facts (Transactional / Measurable Data)**

### **Fact_Fight_Performance** (Core Fact Table)

```
                 Dim_Date
                    |
                    |
Dim_Fighter ——< Fact_Fight_Performance >—— Dim_Event
     |                 |      ^    |
     |                 |      |    |
Dim_WeightClass        |      |    |
                       |      |    |
                     Dim_Method
```

**Grain:**
➡️ One row per fight (1 fight = 1 fact record)

**Foreign Keys:**

* Fighter_1_SK
* Fighter_2_SK
* Event_SK
* Date_SK
* Method_SK
* Weight_Class

---

## 📘 **Dimensions (Descriptive Attributes)**

### **Dim_Fighter**

Fighter profile & long-term attributes
(name, stance, reach, weight class, win/loss, style)

### **Dim_Event**

Event metadata
(date, location, UFC card name)

### **Dim_Date**

Full calendar dimension
(day, month, year, quarter)

### **Dim_Method**

Method of victory
(KO/TKO, Submission, Decision, etc.)

### **Dim_WeightClass**

Lookup for all UFC weight classes

---

# 📚 **Gold Layer Data Catalog**

### **1. gold.Dim_Fighter**

Stores fighter profiles + aggregated stats
Surrogate Key: **Fighter_SK**

### **2. gold.Dim_Event**

Event-level metadata
Surrogate Key: **Event_SK**

### **3. gold.Dim_WeightClass**

Lookup + aggregated fight counts

### **4. gold.Dim_Method**

Method of victory classification

### **5. gold.Dim_Date**

Canonical BI calendar dimension

### **6. gold.Fact_Fight_Performance**

Core fact table supporting analytics on:

* Fight outcomes
* Fighter performance
* Event stats
* Method of victory
* Round/time distribution

### **7. gold.Fact_Event_Metrics**

Aggregated event-level metrics for dashboards

---

# 📊 **Analytics Requirements**

## 🔥 Fighter Performance Insights

* Win/loss ratio per fighter
* Fighters with the most KOs/Submissions
* Average fight duration per fighter
* Strike accuracy vs takedown accuracy trends
* Fighter comparison analytics

---

## 🎪 Event Analytics

* Events with the most fights
* Top hosting cities & countries
* Yearly event activity trends
* Per-event performance summaries

---

## ⚔️ Fight Trends (Global Insights)

* Most common method of victory
* Round-by-round finish distribution
* Fastest / Longest fights
* Weight class performance comparisons

---

# 📦 **Deliverables**

### ✔️ Data Engineering (SQL Server)

* Medallion Architecture (Bronze → Silver → Gold)
* Star Schema (Facts + Dimensions)
* Surrogate Key Design
* SQL DDL + transformations

### ✔️ Data Analytics Queries

* Fighter performance metrics
* Fight outcome analysis
* Event-level summaries
* Method-of-victory KPIs

### ✔️ Documentation

* ERD (Entity Relationship Diagram)
* Data Dictionary / Catalog
* README (this document)
* SQL transformation logic

---

# 📊 **BI / Reporting Layer**

Delivered through SQL queries, ready for:

* Power BI
* Tableau
* Python notebooks
* ML models

Insights include:

* Fighter rankings
* Strike/grappling accuracy trends
* Career progression
* Event summaries
* Weight class analysis

---

# 🏁 **Summary**

This project demonstrates:

* ⭐ Modern Data Engineering
* ⭐ Professional Dimensional Modeling
* ⭐ High-value UFC analytics
* ⭐ Complete portfolio documentation

It is fully suitable for showcasing skills in:

* SQL, ETL, Data Modeling
* Data Warehousing
* BI & Analytics
* Medallion Architecture

---


