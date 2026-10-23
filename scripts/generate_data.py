"""Create reproducible, fictional CSV data matching the course MySQL schema."""
import csv
import random
from datetime import date, timedelta
from pathlib import Path

R = random.Random(42)
OUT = Path(__file__).resolve().parents[1] / 'data'
OUT.mkdir(exist_ok=True)
USERS, SUBSCRIPTIONS, PAYMENTS, NOTIFICATIONS = 5000, 15000, 75000, 30000
PROVIDERS = [(100001+i, f'Demo Stream {i:02d}', f'help{i:02d}@example.com') for i in range(1,24)]


def write(name, headers, rows):
    with (OUT / f'{name}.csv').open('w', newline='', encoding='utf-8') as f:
        w=csv.writer(f);w.writerow(headers);w.writerows(rows)


def iso(d): return d.isoformat()


def random_day(start, end):return start + timedelta(days=R.randint(0,(end-start).days))


write('providers',['ServiceProviderID','ServiceProviderName','ContactInfo'], PROVIDERS)
accounts=[]; profiles=[]; methods=[]; cards=[]; wallets=[]; bridge=[]
for i in range(USERS):
    a=100000+i; m=200000+i
    created=random_day(date(2023,1,1),date(2025,12,31))
    accounts.append((a,f'demo_user_{i+1:05d}','DEMO_NOT_A_PASSWORD_HASH',f'demo_user_{i+1:05d}@example.com',None,iso(created),'U'))
    profiles.append((a,f'Demo{i+1:05d}','Customer',None,None,None,None,None,None,'Fictional'))
    kind= 'Credit Card' if i%2==0 else 'Digital Wallet'
    methods.append((m,a,kind)); bridge.append((300000+i,a,m))
    if kind=='Credit Card':cards.append((m,f'{(i*17)%10000:04d}',iso(date(2030,12,1)),R.choice(['Visa','MasterCard','Amex'])))
    else: wallets.append((m,R.choice(['PayPal','Google Pay','Apple Pay']),f'demo_wallet_{i+1:05d}'))
write('accounts',['AccountID','AccountUsername','EncryptedPassword','Email','PhoneNumber','CreatedOn','AccountType'],accounts)
write('profiles',['AccountID','FirstName','LastName','DateOfBirth','AddressLine1','AddressLine2','City','State','PostalCode','Country'],profiles)
write('methods',['PaymentMethodID','AccountID','MethodType'],methods)
write('credit_cards',['PaymentMethodID','CardNumberLast4','ExpirationDate','CardType'],cards)
write('wallets',['PaymentMethodID','WalletProvider','WalletID'],wallets)
write('account_methods',['AccountPaymentMethodID','AccountID','PaymentMethodID'],bridge)
subs=[]; payments=[]; notifications=[]; emails=[]; sms=[]
for i in range(SUBSCRIPTIONS):
    account_i=i % USERS
    aid=100000+account_i; sid=400000+i; mid=200000+account_i
    pid=PROVIDERS[R.randrange(len(PROVIDERS))][0]
    created=random_day(date(2024,1,1),date(2025,6,30))
    frequency=R.choices(['Monthly','Yearly','Weekly'],weights=[75,15,10])[0]
    cost=R.choice(['5.99','8.99','12.99','15.99','19.99','29.99','49.99','99.99'])
    status=R.choices([3001,3002,3003,3004],weights=[70,8,17,5])[0]
    cancel=random_day(created,date(2026,6,30)) if status==3003 else None
    nextdate=random_day(date(2026,10,23),date(2027,10,22)) if status==3001 else None
    subs.append((sid,f'Demo Plan {pid-100000:02d}',cost,frequency,iso(nextdate) if nextdate else None,aid,mid,pid,status,iso(created),iso(cancel) if cancel else None))
    # Every subscription receives five fictional historical payments.
    for j in range(5):
        paydate=created+timedelta(days=30*j)
        payments.append((500000+i*5+j,sid,iso(paydate),cost,mid))
    for j in range(2):
        nid=700000+i*2+j; nt='Email' if j==0 else 'SMS'
        note_day=created+timedelta(days=7+30*j)
        renewal=note_day+timedelta(days=5)
        notifications.append((nid,aid,sid,iso(note_day),iso(renewal),nt))
        if nt=='Email': emails.append((nid,f'demo_user_{account_i+1:05d}@example.com',aid,sid,'Fictional renewal reminder',iso(note_day)))
        else: sms.append((nid,'+15550000000',aid,sid,'Fictional renewal reminder',iso(note_day)))
write('subscriptions',['SubscriptionID','SubscriptionName','Cost','BillingFrequency','NextBillingDate','AccountID','PaymentMethodID','ServiceProviderID','StatusID','CreateDate','CancellationDate'],subs)
write('payments',['PaymentID','SubscriptionID','PaymentDate','AmountPaid','PaymentMethodID'],payments)
write('notifications',['NotificationID','AccountID','SubscriptionID','NotificationDate','NextBillingDate','NotificationType'],notifications)
write('email_notifications',['NotificationID','EmailAddress','AccountID','SubscriptionID','NotificationContent','NotificationDate'],emails)
write('sms_notifications',['NotificationID','PhoneNumber','AccountID','SubscriptionID','NotificationContent','NotificationDate'],sms)
print(f'Generated {USERS:,} accounts, {SUBSCRIPTIONS:,} subscriptions, {PAYMENTS:,} payments, {NOTIFICATIONS:,} notifications.')
