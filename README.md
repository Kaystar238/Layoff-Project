# Layoff Data Analysis with SQL

##  Project Overview
This project focuses on analyzing layoff data using SQL. It involves cleaning the dataset by identifying and removing duplicate records, structuring data into separate tables, and performing queries to gain insights.

##  Technologies Used
- **SQL** (MySQL or PostgreSQL)
- **Window Functions** (`ROW_NUMBER()`)
- **Common Table Expressions (CTEs)**

##  Dataset Structure
The dataset consists of the following columns:
- `company` - Name of the company
- `location` - Company location
- `industry` - Industry sector
- `total_laid_off` - Number of employees laid off
- `percentage_laid_off` - Percentage of the workforce affected
- `date` - Date of layoff
- `stage` - Stage of the company (e.g., startup, established)
- `country` - Country where the layoffs occurred
- `funds_raised_millions` - Amount of funding raised by the company (if applicable)

##  Key SQL Operations
- **Removing Duplicates:** Using `ROW_NUMBER()` to identify and eliminate duplicate records.
- **Data Cleaning:** Creating temporary tables to store cleaned data.
- **Querying Insights:** Aggregating and filtering data for better understanding.

##  Sample Queries

### Identifying Duplicate Records
```sql
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
        ) AS row_number
    FROM layoffs_copy
)
SELECT * 
FROM duplicate_cte
WHERE row_number > 1;
```

### Removing Duplicates
```sql
DELETE FROM layoffs_copy
WHERE (company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) 
IN (
    SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
    FROM duplicate_cte
    WHERE row_number > 1
);
```

##  How to Use
1. Import the dataset into your SQL database.
2. Run the provided SQL scripts to clean and analyze the data.
3. Modify queries to extract insights specific to your needs.




