# [Fivetran-snowflake-dbt-sigma] NE Finance Intelligence

## Client Profile

| Field | Information |
| --- | --- |
| Company Name | NE Finance Intelligence |
| Industry | Financial watching and analysis SaaS |
| Need | Full data pipeline |
| Requirements | Easy to maintain; role-based security; embedded dashboard |
| Summary | NE Finance Intelligence needs a secure, maintainable data pipeline with embedded dashboard capability for financial watching and analysis. |

## Introduction

This project's goal is to build an end-to-end data pipeline for NE Finance Intelligence using Fivetran to load data from multiple data sources, including databases, Google Drive, and uploaded files, into Snowflake. Snowflake will be used as the main cloud data warehouse, while dbt will be used inside Snowflake to transform raw data into clean, structured, and analysis-ready models and finally use Sigma as visualization Hub. 

## Document Scope

| No. | Section | Description |
| --- | --- | --- |
| 1 | Pipeline Description | Describes how data moves from databases, Google Drive, and uploaded files through Fivetran into Snowflake, then through dbt transformations and visualization. |
| 2 | Snowflake Data Structure | Defines the Snowflake database, schemas, raw tables, staging models, marts, and analytical tables. |
| 3 | Role-Level Security | Explains access control by user roles, permissions, data ownership, and secure dashboard access. |
| 4 | Cost Control and Scale Plan | Covers warehouse sizing, auto-suspend, query optimization, storage management, and future scaling strategy. |
| 5 | CI/CD | Describes the development workflow for dbt models, testing, deployment, version control, and automated release process. |
| 6 | Plan to Improve | Lists future improvements for automation, monitoring, data quality, performance, and dashboard enhancement. |

## 1. Pipeline Description

![Data Pipeline Architecture](nefinance_data_pipeline.png)

- Step 1: Extract data from Database, google drive using Fivetran and load file Earning call to Snowflake stage. 
- Step 2: Transform data by using dbt
- Step 3: Storage transformed data in snowflake database
- Step 4: Visulization data using Sigma 

## 2. Snowflake Data Structure

![Database Structure](nefinance_database_structure.png)

