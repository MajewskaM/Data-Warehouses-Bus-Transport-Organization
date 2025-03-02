# Data-Warehouses
</br>
🌱 University project for the Data Warehouses course. The aim of the project was to design and implement Business Intelligence systems in MS SQL Server.
<br> 

[Bus Transport Data Warehouse implementation in HIVE](https://github.com/MajewskaM/Data-Warehouse-Bus-Transport-HIVE)
</br> --------------------------------------------------------------------------------------------------------------------- </br>

## Project Name: Bus-Transport-Organization


🌱**Specifying requirements for BI system and preparing data sources - business goals and processes defined in the organization**</br>
Documentation of design process include:
- Specification of business processes in Bus Transport Organization - **ProcessesSpecification.pdf**
- Requirements specification for business process - **RequirementsProcessSpecification.pdf**

</br> --------------------------------------------------------------------------------------------------------------------- </br>

🌱**Data sources generator**</br>
RouteTraveller Database and EXCEL files are obtained by the generator implemented in Python.</br>
_Data is loaded into this database using the INSERT and BULK commands </br> 
(RoutesTraveller-bulk-insert-2020.sql, RoutesTraveller-bulk-insert-2021.sql)_

![image](https://github.com/user-attachments/assets/4b32e035-af66-46cf-be79-77b543690191)

Due to large size of the exemplary data in RoutesTraveller Database, it can be downloaded separately -> [RoutesTraveller Data Files](https://www.dropbox.com/scl/fo/88qek6meimnxia1a5v31b/APZl-Qb03VT0uNTyEdBWVIE?rlkey=4gg6iu8e4368186dpfvimbd18&st=v8nh0egn&dl=0)


</br> --------------------------------------------------------------------------------------------------------------------- </br>

🌱**Data Warehouse Design** </br>
Report containing the Data Warehouse design corresponding to the specified requirements – file named **DataWarehouseDesignReport.pdf**
![image](https://github.com/user-attachments/assets/a3e31ef1-307e-4366-abc8-b422ef4690f8)


</br> --------------------------------------------------------------------------------------------------------------------- </br>

🌱**Data Warehouse Implementation**</br>
Data warehouse relational schema – **create_BusTransportDW.sql** </br>
Data views defined in specification in Excel - **Views.xlsx** </br>
Visual Studio Project - **DataWarehouseBusTravel** folder

</br> --------------------------------------------------------------------------------------------------------------------- </br>

🌱**ETL Process implemented in MS SQL Server – Integration Services** </br>
Loading data from the generated data sources into the designed data warehouse and cube processing in ETL process. </br>
Data loading in two time moments: 
- in the first time moment loading all data (Data Sources/RoutesTraveller-bulk-insert-2020.sql)
- in the second time moment new and updated data (Data Sources/RoutesTraveller-bulk-insert-2021.sql, Data Sources/RoutesTraveller-update.sql) </br>

Additionally loading data into SCD (changes can be seen on the Bus AgeCategory and IsCurrent attributes, what can be seen in commented lines in files **ETL_bus_travel.sql** and **ETL_load_bus.sql**).

</br>
Changes introduced in 2021:</br>
1. add more scheduled journeys (schedule table) on routes (dimension table)</br>
2. update of route names (creating sql statements) - change to dimension tables</br>
3. we add a new service office and therefore new buses</br>
</br>
_Travels happening in 2021 generate data referring to the tables: travel, validation, ticket, feedback_

</br> --------------------------------------------------------------------------------------------------------------------- </br>

🌱**MDX Queries**
Formulating, executing MDX queries and implementing KPIs</br>
MDX queries correspond to the ones defined in the requirements specification, analogically KPIs are the implementation of business goals.</br></br>
Report containing MDX queries and KPIs - Data Warehouse Implementation\MDX Queries\ **MDX Queries.pdf**</br>
Excel file with KPI results - Data Warehouse Implementation\MDX Queries\**KPT.xlsx**</br>
Related MDX Queries for analytical problems: **MDXQueries_AnalyticalProblem_1.mdx, MDXQueries_AnalyticalProblem_2.mdx**

</br> --------------------------------------------------------------------------------------------------------------------- </br>

🌱**Data Warehouse Optimization**</br>
Showing the issues related to the various physical models of cubes as well as aggregation design.</br>
1. Performing tests comparing query execution times for different physical cube models with and without aggregations</br>
2. Performing tests comparing cube processing times for various physical cube models with and without aggregations.</br>
3. Comparison of the obtained results with the theoretical assumptions.
</br>  </br>
Report containing the results - **HD_OptimizationReport.pdf**</br>
MDX Queries used - **MDXQueries_3_Optimization.mdx**</br>
Cache results by SSAS server, SQL Server Profiler - example file **CubeProcessingTime.trc**</br>
Cleaning cache script - **XMLA_ClearCache.xmla**

</br> --------------------------------------------------------------------------------------------------------------------- </br>

🌱**BI dashboards**</br>
Illustrating problem of the reports and queries (in Power BI) as defined in the DW specification document.</br>

- Presenting KPI (for different time periods).
- Using different charts.
- All of the reports are parametrizable (eg. The user can choose a year of the
analysis).

**DWvisualisation.pdf** and PowerBI file - **DWvisualisation.pbix**
