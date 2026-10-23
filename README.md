# Subscription Management System | Data Engineering

## Project Overview

This project builds on a subscription management database I developed using MySQL. The original project focused on organizing subscription data, writing SQL queries, and analyzing customer subscriptions, payments, and renewal activity.

I decided to expand the project by adding a Python-based data generation and loading process. This allowed me to work with a larger dataset and focus more on the data engineering side, particularly data preparation, database loading, and maintaining data consistency.

The project uses synthetic data and is intended for portfolio demonstration rather than real-world payment processing.

## Tech Stack

- **Python:** Data generation and database loading
- **MySQL:** Relational database management
- **SQL:** Data validation, querying, and analysis
- **DBeaver:** Database development and management
- **VS Code:** Python development
- **Power BI:** Planned dashboard integration
- **Git & GitHub:** Version control and project documentation

## Project Development

### 1. Database Design and SQL Analysis

I started by building the subscription management database in MySQL, with tables covering accounts, subscriptions, payments, and notifications.

The database supports queries related to subscription activity, upcoming renewals, payment history, and customer accounts.

### 2. Expanding the Dataset with Python

To make the database more suitable for larger-scale analysis, I developed Python scripts that generate fictional subscription records and load them into MySQL.

The expanded dataset contains:

| Table | Records |
|---|---:|
| Accounts | 5,007 |
| Subscriptions | 15,007 |
| Payments | 75,007 |
| Notifications | 30,007 |

These totals include the original seven records in each table.

The Python generator uses a fixed seed, so the dataset can be reproduced consistently.

### 3. Data Loading and Validation

The generated records are first saved as CSV files before being loaded into the MySQL database.

The loading script inserts records into the existing tables without modifying the database structure. It also includes a check to prevent duplicate imports of the generated accounts.

I use SQL queries in DBeaver to verify record counts and check that the data was loaded correctly.

## Data Pipeline

Python Data Generator → CSV Files → Python/MySQL Loader → MySQL Database → SQL Analysis → Power BI (Planned)

## Running the Project

**Requirements**

- Python 3.10 or newer
- MySQL Server
- DBeaver or another SQL client
- Existing `subscription_portfolio` database

**1. Install dependencies**

Open the project folder in VS Code and run:

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

**2. Configure database connection**

Copy `.env.example` to `.env` and update it with your MySQL credentials.

The `.env` file is excluded from GitHub to protect local database credentials.

**3. Generate sample records**

```powershell
.\.venv\Scripts\python.exe scripts\generate_data.py
```

**4. Load records into MySQL**

```powershell
.\.venv\Scripts\python.exe scripts\load_mysql.py
```

**5. Validate the data**

Open `sql/check_data.sql` in DBeaver and execute the validation queries.

## Notes

All records generated for this project are fictional. The dataset does not contain actual customer information, payment card details, or password hashes.

The payment history is simulated for database and SQL analysis, not financial reporting.

The generated CSV files are excluded from the repository because they can be recreated using the Python generator.

The loader adds records to the existing database, and running the original database reset script afterward may remove the additional data.

## Next Steps

I'm continuing to develop this project with a focus on strengthening the data pipeline and making the database more useful for reporting and analytics.

Planned improvements include:

- Automated data quality checks and unit tests
- Incremental data loading
- API-based data ingestion
- More advanced SQL transformations and reporting views
- Power BI integration for subscription and payment analysis

## Project Focus

My background is primarily in data analytics, where I've worked with SQL, Python, reporting, and dashboards to turn data into business insights.

With this project, I'm extending that experience into data engineering by focusing on how data is generated, loaded, validated, and structured before it reaches the reporting stage.

The longer-term goal is to develop a more complete pipeline that connects data ingestion, transformation, storage, and business intelligence.
