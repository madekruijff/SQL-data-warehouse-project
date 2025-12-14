# Data Warehouse and Analytics Project

Hello, hello and welcome to this data warehouse project! This is a guided project by Baraa Khatib Salkini (aka [Data With Baraa](https://www.blog.datawithbaraa.com/)). You can find the YouTube explanation [here](https://www.youtube.com/watch?v=9GVqKuTVANE). The abridged version and explanations will be displayed on GitHub, but you can find the comprehensive version on my [Data Science Portfolio Website](LINK)!

This project demonstrates a comprehensive data warehousing and analytics workflow, from importing and cleaning data to generation of actionable insights. As a training project, it highlights industry best practices in data engineering and analytics. 


---
## :clipboard: Project Overview

This project involves:

  1. **Data Architecture**: Designing a 'Modern Data Warehouse' using the Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
  2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
  3. **Data Modeling**: Developing fact and dimension tables, linked by primary and foreign keys, optimized for analytical queries.
  4. **Analytics and Reporting**: Creating SQL-based reports and dashboards for actionable insights.


:brain: This project is excellent to improve expertise in:

  - SQL Development
  - Data Architect
  - Data Engineering
  - ETL Pipeline Developer
  - Data Modeling
  - Data Analytics

---
## :bricks: Important Links and Tools:

The following datasets and tools were used:
- **[Datasets](datasets/):** The CSV files used for the Data Warehouse project.
- **[Microsoft SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads):** Lightweight server for hosting  SQL databases.
- **[SQL Server Management Studio (SSMS)](https://learn.microsoft.com/en-us/ssms/install/install):** GUI for managing and interacting with databases.
- **[Git Repository](https://github.com/):** GitHub repository to manage, version, and collaborate on code efficiently.
- **[DrawIO](https://www.drawio.com/):** Design software used for the Data Architecture figure.
- **[Canva](https://www.canva.com/):** Design software used for Data Flow and Data Integration figures.
- **[Data Science Portfolio Website](LINK):** Full display of the project.

---

## :construction: Data Architecture
The data architecture for this project follows 'Medallion Architecture' **Bronze**, **Silver**, and **Gold** layers: 
1. **Bronze Layer**: Stores the raw data directly from the source (CSV files) into the SQL Database.
2. **Silver Layer**: Includes cleaned, standardized, and normalized data, prepared for analysis.
3. **Gold Layer**: Harbours business-ready data facilitated in a star schema for reporting and furtheranalytics.

---
## 📂 Repository Structure
```
data-warehouse-project/
│
├── datasets/                               # Raw datasets used for the project (ERP and CRM data in CSV format)
│
├── docs/                                   # Project documentation and architecture details
│   ├── Data_Warehouse_architecture.drawio  # Draw.io file shows the project's data architecture
│   ├── Data_catalog.md                     # Catalog of datasets, including field descriptions and metadata
│   ├── Data_Flow.png                       # PNG file for the data flow diagram
│   ├── Data_Model_(Star_Schema).png        # PNG file for data models (Star Schema)
│
├── scripts/                                # SQL scripts for ETL and analysis preparation
│   ├── bronze/                             # Scripts for extracting and loading raw data
│   ├── silver/                             # Scripts for cleaning and transforming data
│   ├── gold/                               # Scripts for creating analytical models
│
├── tests/                                  # Test scripts and quality files
│
├── README.md                               # Project overview and instructions
├── LICENSE                                 # License information for the repository
├── .gitignore                              # Files and directories to be ignored by Git
└── requirements.txt                        # Dependencies and requirements for the project
```
---
## :judge: License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.
