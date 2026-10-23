"""Load the generated CSVs into an existing subscription_portfolio MySQL schema."""
import csv
import os
from pathlib import Path

import mysql.connector
from dotenv import load_dotenv

ROOT=Path(__file__).resolve().parents[1]
load_dotenv(ROOT/'.env')
DB=os.getenv('MYSQL_DATABASE','subscription_portfolio')
if DB!='subscription_portfolio':
    raise SystemExit('Safety check: MYSQL_DATABASE must be subscription_portfolio')

# Tables must already exist (run the provided 01 schema script first).
FILES = [
 ('providers','ServiceProvider'),('accounts','Account'),('profiles','UserProfile'),
 ('methods','PaymentMethod'),('credit_cards','CreditCardPayment'),('wallets','DigitalWalletPayment'),
 ('account_methods','AccountPaymentMethod'),('subscriptions','Subscription'),
 ('payments','Payment'),('notifications','Notification'),
 ('email_notifications','EmailNotification'),('sms_notifications','SMSNotification')]


def load_file(cur,filename,table):
    path=ROOT/'data'/f'{filename}.csv'
    with path.open(newline='',encoding='utf-8') as handle:
        reader=csv.DictReader(handle)
        names=reader.fieldnames
        if not names:raise ValueError(f'Empty file {path}')
        placeholders=','.join(['%s']*len(names))
        cols=','.join(f'`{c}`' for c in names)
        sql=f'INSERT INTO `{table}` ({cols}) VALUES ({placeholders})'
        batch=[];count=0
        for item in reader:
            batch.append(tuple(item[k] if item[k]!='' else None for k in names))
            if len(batch)>=1000:
                cur.executemany(sql,batch);count+=len(batch);batch=[]
        if batch:cur.executemany(sql,batch);count+=len(batch)
    print(f'{table}: {count:,} inserted')


def main():
    if not os.getenv('MYSQL_PASSWORD'):
        raise SystemExit('Put MYSQL_PASSWORD in your .env file. Do not add .env to GitHub.')
    conn=mysql.connector.connect(host=os.getenv('MYSQL_HOST','localhost'),port=int(os.getenv('MYSQL_PORT','3306')),
                                 user=os.getenv('MYSQL_USER','root'),password=os.environ['MYSQL_PASSWORD'],database=DB)
    try:
        cur=conn.cursor()
        cur.execute('SELECT COUNT(*) FROM Account WHERE AccountID >= 100000 AND AccountID < 105000')
        if cur.fetchone()[0]:
            raise SystemExit('Synthetic accounts already exist. Skipping import to avoid duplicates.')
        # Explicit IDs are reserved in high ranges; preserve original seven course records.
        for name, table in FILES:load_file(cur,name,table)
        conn.commit()
        print('All inserts committed successfully.')
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()

if __name__=='__main__':main()
