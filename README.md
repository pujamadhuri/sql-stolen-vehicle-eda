
# SQL Exploratory Data Analysis of Stolen Vehicles in Salt Lake City (2012–2013)

## 📌 Project Overview
This project presents an end-to-end **SQL-based Exploratory Data Analysis (EDA)** of stolen vehicle incidents reported in **Salt Lake City** for the years **2012 and 2013**. The objective of this analysis is to clean, consolidate, and analyze real-world public safety data to uncover **temporal, geographic, and behavioral patterns** in vehicle thefts.

The project is designed as a **portfolio-ready case study**, demonstrating practical data analyst skills including data cleaning, deduplication, transformation, analytical querying, and data visualization using **MySQL and Tableau**.

---

## 📂 Dataset
The datasets were obtained from **Open Data Utah (data.utah.gov)**:
- **SLC Stolen Vehicles – 2012**
- **SLC Stolen Vehicles – 2013**

**Source Links:**  
- https://opendata.utah.gov/Public-Safety/Stolen-Vehicles-2012-Salt-Lake-City/f48d-qvk9  
- https://opendata.utah.gov/Public-Safety/Stolen-Vehicles-SLC-2013/anx8-4kha  

**Format:** CSV  
**Records:** 4,763 combined cases  

**Key Columns:**  
Case, offense code, offense description, report date, occurrence date, day of week, location, location 1  

*Note: Raw datasets are not included in this repository.*

---

## 🛠 Tools & Technologies
- **Database:** MySQL 8.0+
- **Query Techniques:**  
  - CTEs & Window Functions (`ROW_NUMBER()`)  
  - Aggregations & Grouping  
  - Date & Time Functions  
  - Conditional Logic (`CASE WHEN`)
- **Visualization:** Tableau Public

---

## 📁 Project Structure
- **cleaned_final_dataset.csv** – Final cleaned dataset  
- **slc_stolen_vehicle.sql** – SQL scripts for database creation, data import, cleaning, deduplication, and EDA  
- **README.md** – Project overview, workflow, and execution instructions  

---

## 🔄 Data Preparation & Cleaning
To ensure data integrity and reproducibility, a structured multi-layer approach was followed:

### 1. Backup & Staging Tables
- Original raw tables were preserved using backup tables.
- Separate staging tables were created for the 2012 and 2013 datasets to perform cleaning without impacting raw data.

### 2. Deduplication
- Duplicate records were identified using `ROW_NUMBER()` partitioned by **Case Number** and **Report Date**.
- Because MySQL CTEs are not directly updatable, a secondary staging table was created to safely remove duplicates while retaining the earliest occurrence.

### 3. Data Type Standardization
- Date fields originally stored as text were converted to **DATE/DATETIME** formats using `STR_TO_DATE()`.
- Inconsistent date formats between years were normalized.

### 4. Data Validation
- Records outside the expected year range (e.g., misclassified 2014 entries in the 2013 dataset) were identified and removed.
- Column naming inconsistencies (e.g., offense codes) were standardized.

---

## 🧱 Final Analytics Table
A consolidated analytics table, `slc_stolen_final`, was created using `UNION ALL` to combine the cleaned 2012 and 2013 datasets. This table serves as the **single source of truth** for all analytical queries and visualizations.

---

## 🔍 Exploratory Data Analysis (SQL)

### 📈 Theft Trends Over Time
- Total vehicle thefts by year  
- Monthly trends to identify seasonality  
- Average monthly thefts per year  

### 🕒 Time-Based Patterns
- Theft distribution by hour of day  
- Weekday vs. weekend comparison  
- Day-of-week analysis  

### 📍 Location Analysis
- Top locations with the highest number of reported thefts  

### 🌦 Seasonal Analysis
- Comparison of theft incidents across Winter, Spring, Summer, and Fall  

These analyses help identify **peak periods, high-risk locations, and behavioral trends** associated with vehicle thefts.

---

## ▶️ How to Run This Project
1. Clone this repository.
2. Download the 2012 and 2013 datasets from **data.utah.gov** using the links above.
3. Import the CSV files into a MySQL database.
4. Execute the SQL scripts in `slc_stolen_vehicle.sql` to:
   - Create backup and staging tables  
   - Perform data cleaning and deduplication  
   - Generate the final analytics table  
5. Use the cleaned dataset to recreate the Tableau dashboard.

---

## 📊 Tableau Visualization
The cleaned and consolidated dataset was visualized using **Tableau** to create an interactive dashboard that highlights key patterns identified during SQL analysis.

🔗 **Explore the live dashboard:**  
https://public.tableau.com/app/profile/puja.madhuri.k/viz/SLCStolenVehicleAnalysis20122013/Dashboard1#1  

The dashboard includes:
- **Total Vehicle Thefts by Year:** Year-over-year comparison of reported thefts  
- **Monthly Vehicle Theft Trends:** Seasonality and monthly fluctuations  
- **Top 10 Locations with Highest Vehicle Thefts:** Geographic hotspots  
- **Vehicle Thefts by Day of Week:** Behavioral patterns across weekdays  
- **Theft by Hour of Day:** Identification of peak theft hours  

These visualizations translate SQL insights into an intuitive, interactive format for both technical and non-technical audiences.

---

## 💡 Key Insights
- Vehicle thefts show clear **seasonal and monthly patterns**.
- Certain locations consistently report higher theft volumes.
- Theft frequency varies noticeably by **time of day** and **day type (weekday vs. weekend)**.

---

## 🎯 Skills Demonstrated
- Real-world data cleaning and validation  
- SQL window functions and complex aggregations  
- Analytical thinking and pattern recognition  
- End-to-end data workflow (raw data → insights → visualization)  
- Well-documented, reproducible SQL analysis using staging and final tables  

---

## 🙏 Acknowledgements
Data for this project was sourced from **Open Data Utah (data.utah.gov)**.

---

**Author:**  
**Puja Madhuri K**  
Aspiring Data Analyst  

🔗 GitHub: https://github.com/pujamadhuri/sql-stolen-vehicle-eda
