# Subscription Management — Synthetic Data Engineering Extension

Extends the existing MySQL `subscription_portfolio` course database with reproducible **fictional** sample records. Intended for portfolio and local learning, **not a live payment system**. Contains no real payment card data or password hashes. Generated phone numbers and emails are illustrative only.

## Prerequisites
- Working MySQL Server and DBeaver, with the original `subscription_portfolio` tables already created
- Python 3.10+

## How to run (Windows PowerShell / VS Code terminal)
1. Extract this folder. Open it in VS Code (File > Open Folder).
2. Create the virtual environment and install dependencies:

   ```powershell
   py -m venv .venv
   .\.venv\Scripts\python.exe -m pip install -r requirements.txt
   ```

3. Copy `.env.example` to `.env` and put **your actual MySQL password** there. The `.env` file is ignored by Git. You can edit the username if necessary. Do **not** publish `.env`.
4. Generate CSV files:

   ```powershell
   .\.venv\Scripts\python.exe scripts\generate_data.py
   ```

5. Load them into the already-created database:

   ```powershell
   .\.venv\Scripts\python.exe scripts\load_mysql.py
   ```

6. In DBeaver run the statements in `sql/check_data.sql` **one statement at a time (Ctrl+Enter)**, or use Execute SQL Script (Alt+X).

Expected data *including the original seven course records*: 5,007 accounts, 15,007 subscriptions, 75,007 payments, 30,007 notifications (assuming you started from the original seven records).

## Safety and scope
- The generator only writes local CSV files, and the loader only **inserts** into `subscription_portfolio` tables; it does not drop tables or change schema.
- Running the generator again is safe (same seeded output). Running the loader twice is intentionally blocked for the synthetic account ID range.
- Do not rerun the original reset/setup SQL after importing; that would delete the synthetic records.
- The `data/` CSV outputs are ignored by Git due to their size. GitHub stores your **code**; a reader can recreate all data by running the generator. GitHub does not host your local MySQL server or execute the dashboard.
- The historical payment events are synthetic, approximate and generated for SQL practice. Do not interpret their amounts as actual revenue or their sequence as rigorous billing behavior.
- Existing 2024 sample dates are retained rather than updated.

## Architecture
`Python CSV generator -> CSV source files -> Python/MySQL batch loader -> MySQL normalized tables -> DBeaver SQL queries -> future Power BI`.

## Future improvements
- Add data quality unit tests and incremental processing
- Move from generated files to API ingestion
- Add dashboard views with better business metrics and date modeling
- Avoid using demo placeholder password values for any real authentication
