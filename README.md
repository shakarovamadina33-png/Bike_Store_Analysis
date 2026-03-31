# BikeStore: SQL-Powered Retail Performance System

## Project Overview
This project implements a complete **Business Intelligence (BI) solution** using SQL Server for a retail bike sales company.The goal is to transform raw transactional data from CSV files into actionable business insights through a structured data model, KPI-focused views, and reusable stored procedures.

The project simulates a real-world analytics workflow, covering everything from schema design and automated data ingestion to performance reporting and decision support.

## Database Schema & ER Diagram
![ER Diagram](https://raw.githubusercontent.com/shakarovamadina33-png/Bike_Store_Analysis/main/Diagram/photo_2026-03-31_20-51-55.jpg)

**Description:**
This ER diagram represents the **normalized relational database schema** for the Bike Store sales system.The schema is designed to support transactional sales analysis, inventory tracking, and staff performance reporting.It includes core entities such as Orders, Customers, Products, Stores, Staff, and Inventory.

## Project Objectives
* **Data Ingestion & Transformation:** Load and normalize CSV-based datasets using `BULK INSERT` and staging table logic.
* **Relational Modeling:** Build a clean schema with proper keys, types, and constraints to ensure data integrity.
* **Automated Reporting:** Design production-grade SQL views for high-level business metrics.
* **Workflow Automation:** Implement stored procedures and SQL Server Agent jobs to automate data updates and KPI calculations.

## Key Performance Indicators (KPIs)
The system calculates the following essential BI metrics:
* **Total Revenue:** Overall company-wide financial performance.
* **Average Order Value (AOV):** Analysis of customer spending behavior.
* **Inventory Turnover:** Efficiency of stock flow and management.
* **Revenue by Store/Brand:** Identification of top-performing branches and vendor effectiveness.
* **Staff Productivity:** Tracking revenue contribution per staff member.

## Technical Implementation

### 1. SQL Views (Automated Reports)
* `vw_StoreSalesSummary`: Revenue, order count, and AOV per store.
* `vw_TopSellingProducts`: Ranking products by total sales.
* `vw_InventoryStatus`: Real-time monitoring of low-stock items.
* `vw_StaffPerformance`: Sales performance metrics for each staff member.
* `vw_RegionalTrends`: Revenue breakdown by city or region.
* `vw_SalesByCategory`: Sales volume and profit margins by category.

### 2. Stored Procedures
* `sp_CalculateStoreKPI`: Returns a full KPI breakdown for a specific store.
* `sp_GenerateRestockList`: Automatically outputs low-stock items needing attention.
* `sp_CompareSalesYearOverYear`: Comparative analysis of sales between two years.
* `sp_GetCustomerProfile`: Detailed metrics including total spend and purchase history.

### 3. Automation
A **SQL Server Agent Job** is configured to automate the following tasks:
Daily/Weekly ingestion of new `.csv` files from a source folder.
Execution of stored procedures to refresh reporting tables.

## Tools & Technologies
* **Database:** SQL Server
* **Language:** T-SQL (Joins, CTEs, Window Functions, Aggregations)
* **Automation:** SQL Server Agent
* **Modeling:** Normalized Relational Schema (ER Modeling)
