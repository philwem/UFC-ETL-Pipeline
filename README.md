# 🥋UFC Data Warehouse
Welcome to the UFC Data Warehouse and Analytics repository! 
This project demonstrates a comprehensive data warehousing and analytics solution using real-world style UFC datasets. From building a star schema warehouse to generating actionable insights, this project is designed as a portfolio showcase of industry best practices in data engineering and analytics.
## Project Requirements
Building the Data Warehouse (Data Engineering)
## Objective
Design and implement a modern star schema data warehouse in SQL Server using medallion architecture (Bronze-Silver-Gold layers) to consolidate UFC events, fights, fighters, and fighter statistics data, enabling analytical reporting, performance tracking, and support for business intelligence queries about fighter performance, fight outcomes, and event trends.
## Specifications
### Source Data  (CSVs) :
*events.csv* → event details (metadata about each event)

*fighters.csv* → fighter profile information

*fighter_stats.csv* → aggregate performance statistics per fighter

*fights.csv* → records of individual fight outcomes
### Data Quality:
Cleanse and resolve data quality issues (duplicates, missing values, inconsistent formats).
### Integration:
Combine all sources into a unified, user-friendly star schema designed for analytical queries.
### Scope:
Focus on the latest available datasets; historization is not required.
### Documentation: 
Provide clear documentation of the data model, transformations, and queries for both technical and non-technical stakeholders.

## Warehouse Design
## 🏗Facts (actions/transactions)
### FactFights (core fact table)
fight_id

event_id (FK → DimEvent)

fighter1_id (FK → DimFighter)

fighter2_id (FK → DimFighter)

winner_id (FK → DimFighter)

method_id (FK → DimMethod)

round, time, fight_duration, date_id (FK → DimDate)

## (Optional)
**FactFighterStats** → if you want to keep fighter_stats.csv as a separate fact for per-fighter aggregated performance.


## 🧾Dimensions (descriptive attributes)
### DimFighter
fighter_id, name, country, stance, height, reach, dob
## DimEvent
event_id, event_name, event_date, location
## DimDate
date_id, full_date, day, month, year, quarter
## DimMethod
method_id, method_type (KO/TKO, Decision, Submission, etc.)

##(and optionally FactFighterStats linked to DimFighter)

## Analytics Requirements

### Fighter Performance
Win/Loss ratio per fighter

Fighters with the most finishes (KO/Submissions)

Average fight duration per fighter

### Event Analytics
Events with the most fights

Top locations by number of events

Event activity trend (fights per year/quarter)

### Fight Trends
Most common winning method overall

Round distribution of finishes (most fights ending in round 1, etc.)

Country-level fighter performance comparison

## Deliverables
Data Warehouse Schema (star schema implemented in SQL Server)

ETL Process (staging CSVs → cleansing → load to DW)

SQL Queries for insights above

**Documentation:**
ERD (star schema diagram)

Data dictionary (tables + columns)

README in GitHub

## BI: Analytics & Reporting (Data Analytics)
### Objective
Develop SQL-based analytics to deliver detailed insights into:

Fighter Performance (win/loss ratios, finish rates, average fight duration)

Event Analytics (most active venues, event activity over time, fights per event)

Fight Trends (most common winning methods, round/time distributions, country-level comparisons)

This version is industry-standard:
No ERP/CRM shortcut labels

Pure Fact + Dimension modeling (Kimball method)

Easy for any engineer/analyst to understand





