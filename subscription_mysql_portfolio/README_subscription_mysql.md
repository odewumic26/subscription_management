# Subscription Management Database (MySQL 8.0+)

Converted from an academic SQL Server subscription-management project to MySQL. Includes a relational schema, sample subscription/payment records, account/profile tables, subtype tables for payment methods and notifications, CRUD-style stored procedures, a billing-date history trigger, a view, and analytics queries.

## Quick start with DBeaver

1. Connect to your **MySQL** database server on `localhost:3306`.
2. Open a SQL editor attached to that connection.
3. Run **`subscription_mysql_01_schema_data.sql`** using **SQL Editor → Execute SQL Script** (Alt+X).
4. Run **`subscription_mysql_02_procedures_trigger.sql`** as a script. It uses `DELIMITER $$` to define stored procedures/triggers. If your DBeaver version does not process `DELIMITER` correctly, run that script using MySQL Workbench or the MySQL command-line client. Do not send the `DELIMITER` lines directly to the server as standalone SQL statements.
5. Run **`subscription_mysql_03_analysis_tests.sql`** for analysis and verification.

**WARNING:** The first script recreates tables within `subscription_portfolio` and deletes existing data *in that schema*. Back up any data you want to preserve first. Other databases are not modified.

## What was changed

- SQL Server-only `GO`, `OBJECT_ID`, `GETDATE`, `SCOPE_IDENTITY`, `NEXT VALUE FOR`, `IDENTITY`, `TRY/CATCH`, `RAISERROR`, and `INSERTED/DELETED` syntax replaced with MySQL-compatible design and routines.
- Used `AUTO_INCREMENT` for generated IDs; preserved original demonstration IDs.
- Corrected foreign-key cleanup ordering and required ID insertion issues.
- Reconciled email/SMS notification example records to the parent notification type.
- Fixed upcoming-renewal procedure to query the `UpcomingRenewals` view.
- Rewrote trigger using MySQL `OLD`/`NEW` row values.
- Included sample-data verification and dashboard-ready analytical queries.

## Scope and limitations

- **No actual email/SMS is sent**; notification procedures log records only.
- `EncryptedPassword` contains clearly labeled demo placeholders, **not password hashes**. A production service needs proper password hashing in application code (Argon2id/bcrypt), authentication and authorization.
- Historic sample subscription billing dates (2024–25) mean the future-renewals view will show no rows in 2026 unless demo dates are updated.
- This is a database and SQL portfolio demonstration, not a deployed subscription management app. No real payment processing or PCI-compliant storage is provided.
- Some procedures deliberately enforce consistency instead of imitating unsafe original behavior (e.g. `UpdatePaymentMethod` refuses to relabel an existing card as a wallet without migrating subtype data).
- MySQL version requirements: 8.0.16+ for enforced CHECK constraints. Intended for a modern MySQL 8+/9+ server; not verified by a live MySQL server in the creation environment.

## Suggested next improvements

- Add automated integration tests against a disposable local database.
- Introduce fake subscription records covering current dates and recurring events.
- Use Python to ingest CSV data and produce a Power BI dashboard based on a documented dataset.
