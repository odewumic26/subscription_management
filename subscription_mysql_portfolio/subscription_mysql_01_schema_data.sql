CREATE DATABASE IF NOT EXISTS subscription_portfolio CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE subscription_portfolio;

DROP VIEW IF EXISTS UpcomingRenewals;
DROP TABLE IF EXISTS SubscriptionHistory;
DROP TABLE IF EXISTS AccountPaymentMethod;
DROP TABLE IF EXISTS EmailNotification;
DROP TABLE IF EXISTS SMSNotification;
DROP TABLE IF EXISTS Notification;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS CreditCardPayment;
DROP TABLE IF EXISTS DigitalWalletPayment;
DROP TABLE IF EXISTS Subscription;
DROP TABLE IF EXISTS PaymentMethod;
DROP TABLE IF EXISTS UserProfile;
DROP TABLE IF EXISTS `Status`;
DROP TABLE IF EXISTS ServiceProvider;
DROP TABLE IF EXISTS Account;

CREATE TABLE Account (
 AccountID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 AccountUsername VARCHAR(64) NOT NULL UNIQUE,
 EncryptedPassword VARCHAR(255) NOT NULL,
 Email VARCHAR(255) NOT NULL UNIQUE,
 PhoneNumber VARCHAR(20),
 CreatedOn DATE NOT NULL DEFAULT (CURRENT_DATE),
 AccountType CHAR(1) NOT NULL,
 CONSTRAINT chk_account_type CHECK (AccountType IN ('U','A'))
) ENGINE=InnoDB AUTO_INCREMENT=1001;

CREATE TABLE UserProfile (
 AccountID BIGINT NOT NULL PRIMARY KEY,
 FirstName VARCHAR(255) NOT NULL, LastName VARCHAR(255) NOT NULL,
 DateOfBirth DATE, AddressLine1 VARCHAR(255), AddressLine2 VARCHAR(255),
 City VARCHAR(255), State VARCHAR(255), PostalCode VARCHAR(20), Country VARCHAR(255),
 FOREIGN KEY (AccountID) REFERENCES Account(AccountID) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE ServiceProvider (
 ServiceProviderID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 ServiceProviderName VARCHAR(50) NOT NULL UNIQUE,
 ContactInfo VARCHAR(255)
) ENGINE=InnoDB AUTO_INCREMENT=2001;

CREATE TABLE `Status` (
 StatusID BIGINT NOT NULL PRIMARY KEY,
 StatusName VARCHAR(50) NOT NULL UNIQUE,
 CONSTRAINT chk_status CHECK (StatusName IN ('Active','Inactive','Canceled','Pending'))
) ENGINE=InnoDB;

CREATE TABLE PaymentMethod (
 PaymentMethodID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 AccountID BIGINT,
 MethodType VARCHAR(50) NOT NULL,
 CONSTRAINT chk_method_type CHECK (MethodType IN ('Credit Card','Digital Wallet')),
 FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
) ENGINE=InnoDB AUTO_INCREMENT=4001;

CREATE TABLE Subscription (
 SubscriptionID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 SubscriptionName VARCHAR(50) NOT NULL,
 Cost DECIMAL(7,2) NOT NULL,
 BillingFrequency VARCHAR(50) NOT NULL,
 NextBillingDate DATE,
 AccountID BIGINT NOT NULL,
 PaymentMethodID BIGINT,
 ServiceProviderID BIGINT NOT NULL,
 StatusID BIGINT NOT NULL,
 CreateDate DATE NOT NULL DEFAULT (CURRENT_DATE),
 CancellationDate DATE,
 CONSTRAINT chk_billing_freq CHECK (BillingFrequency IN ('Monthly','Yearly','Weekly','Other')),
 CONSTRAINT chk_cost_nonnegative CHECK (Cost >= 0),
 FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
 FOREIGN KEY (ServiceProviderID) REFERENCES ServiceProvider(ServiceProviderID),
 FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID),
 FOREIGN KEY (StatusID) REFERENCES `Status`(StatusID),
 INDEX idx_subscription_nextbillingdate (NextBillingDate),
 INDEX idx_subscription_billingfrequency (BillingFrequency)
) ENGINE=InnoDB AUTO_INCREMENT=5001;

CREATE TABLE CreditCardPayment (
 PaymentMethodID BIGINT NOT NULL PRIMARY KEY,
 CardNumberLast4 CHAR(4) NOT NULL,
 ExpirationDate DATE NOT NULL,
 CardType VARCHAR(50) NOT NULL,
 CONSTRAINT chk_cardtype CHECK (CardType IN ('Visa','MasterCard','Amex')),
 FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID)
) ENGINE=InnoDB;

CREATE TABLE DigitalWalletPayment (
 PaymentMethodID BIGINT NOT NULL PRIMARY KEY,
 WalletProvider VARCHAR(255) NOT NULL,
 WalletID VARCHAR(255) NOT NULL UNIQUE,
 CONSTRAINT chk_wallet CHECK (WalletProvider IN ('PayPal','Google Pay','Apple Pay')),
 FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID)
) ENGINE=InnoDB;

CREATE TABLE Payment (
 PaymentID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 SubscriptionID BIGINT NOT NULL,
 PaymentDate DATE NOT NULL,
 AmountPaid DECIMAL(7,2) NOT NULL,
 PaymentMethodID BIGINT,
 CONSTRAINT chk_amount_nonnegative CHECK (AmountPaid >= 0),
 FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID),
 FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID)
) ENGINE=InnoDB AUTO_INCREMENT=6001;

CREATE TABLE Notification (
 NotificationID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 AccountID BIGINT NOT NULL,
 SubscriptionID BIGINT NOT NULL,
 NotificationDate DATE NOT NULL,
 NextBillingDate DATE NOT NULL,
 NotificationType VARCHAR(10) NOT NULL,
 CONSTRAINT chk_notification_type CHECK (NotificationType IN ('Email','SMS')),
 FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
 FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID)
) ENGINE=InnoDB AUTO_INCREMENT=7001;

CREATE TABLE EmailNotification (
 NotificationID BIGINT NOT NULL PRIMARY KEY,
 EmailAddress VARCHAR(255) NOT NULL,
 AccountID BIGINT, SubscriptionID BIGINT,
 NotificationContent TEXT, NotificationDate DATE,
 FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
 FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID),
 FOREIGN KEY (NotificationID) REFERENCES Notification(NotificationID)
) ENGINE=InnoDB;

CREATE TABLE SMSNotification (
 NotificationID BIGINT NOT NULL PRIMARY KEY,
 PhoneNumber VARCHAR(20) NOT NULL,
 AccountID BIGINT, SubscriptionID BIGINT,
 NotificationContent TEXT, NotificationDate DATE,
 FOREIGN KEY (AccountID) REFERENCES Account(AccountID),
 FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID),
 FOREIGN KEY (NotificationID) REFERENCES Notification(NotificationID)
) ENGINE=InnoDB;

CREATE TABLE AccountPaymentMethod (
 AccountPaymentMethodID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 AccountID BIGINT NOT NULL,
 PaymentMethodID BIGINT NOT NULL,
 UNIQUE KEY uq_account_payment_method (AccountID, PaymentMethodID),
 FOREIGN KEY (AccountID) REFERENCES Account(AccountID) ON DELETE CASCADE,
 FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethod(PaymentMethodID) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1001;

CREATE TABLE SubscriptionHistory (
 HistoryID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
 SubscriptionID BIGINT NOT NULL, AccountID BIGINT NOT NULL,
 OldNextBillingDate DATE, NewNextBillingDate DATE,
 ChangeDate DATE NOT NULL DEFAULT (CURRENT_DATE),
 FOREIGN KEY (SubscriptionID) REFERENCES Subscription(SubscriptionID),
 FOREIGN KEY (AccountID) REFERENCES Account(AccountID)
) ENGINE=InnoDB;

INSERT INTO Account (AccountID, AccountUsername, EncryptedPassword, Email, PhoneNumber, CreatedOn, AccountType) VALUES
 (1001,'user1','DEMO_NOT_A_PASSWORD_HASH','user1@example.com','1234567890','2022-01-01','U'),
 (1002,'user2','DEMO_NOT_A_PASSWORD_HASH','user2@example.com','2345678901','2022-02-01','U'),
 (1003,'user3','DEMO_NOT_A_PASSWORD_HASH','user3@example.com','3456789012','2022-03-01','U'),
 (1004,'user4','DEMO_NOT_A_PASSWORD_HASH','user4@example.com','4567890123','2022-04-01','A'),
 (1005,'user5','DEMO_NOT_A_PASSWORD_HASH','user5@example.com','5678901234','2022-05-01','U'),
 (1006,'user6','DEMO_NOT_A_PASSWORD_HASH','user6@example.com','6789012345','2022-06-01','A'),
 (1007,'user7','DEMO_NOT_A_PASSWORD_HASH','user7@example.com','7890123456','2022-07-01','U');
INSERT INTO UserProfile (AccountID,FirstName,LastName,DateOfBirth,AddressLine1,AddressLine2,City,State,PostalCode,Country) VALUES
 (1001,'John','Doe','1990-01-01','123 Main St','Apt 1','Boston','Massachusetts','02108','USA'),
 (1002,'Jane','Smith','1985-02-15','456 Oak St','Suite 200','Springfield','Illinois','62701','USA'),
 (1003,'David','Johnson','1992-03-20','789 Pine St','Apt 2','San Francisco','California','94102','USA'),
 (1004,'Emily','Brown','1995-04-25','101 Maple St','Floor 3','Austin','Texas','73301','USA'),
 (1005,'Michael','Williams','1988-05-10','202 Cedar St','Unit 5','Seattle','Washington','98101','USA'),
 (1006,'Sarah','Taylor','1991-06-05','303 Elm St','Bungalow','Miami','Florida','33101','USA'),
 (1007,'James','Anderson','1987-07-30','404 Birch St','House 10','Denver','Colorado','80201','USA');
INSERT INTO ServiceProvider (ServiceProviderID,ServiceProviderName,ContactInfo) VALUES
 (2001,'Netflix','support@netflix.com'),(2002,'Spotify','support@spotify.com'),
 (2003,'Amazon Prime','support@amazon.com'),(2004,'Hulu','support@hulu.com'),
 (2005,'Disney+','support@disneyplus.com'),(2006,'HBO Max','support@hbomax.com'),
 (2007,'YouTube Premium','support@youtube.com');
INSERT INTO `Status` (StatusID,StatusName) VALUES
 (3001,'Active'),(3002,'Inactive'),(3003,'Canceled'),(3004,'Pending');
INSERT INTO PaymentMethod (PaymentMethodID,AccountID,MethodType) VALUES
 (4001,1001,'Credit Card'),(4002,1002,'Credit Card'),(4003,1003,'Digital Wallet'),
 (4004,1004,'Credit Card'),(4005,1005,'Digital Wallet'),(4006,1006,'Credit Card'),(4007,1007,'Digital Wallet');
INSERT INTO Subscription (SubscriptionID,AccountID,ServiceProviderID,PaymentMethodID,SubscriptionName,Cost,BillingFrequency,NextBillingDate,StatusID,CancellationDate,CreateDate) VALUES
 (5001,1001,2001,4001,'Netflix Standard',12.99,'Monthly','2024-10-15',3001,NULL,'2024-01-01'),
 (5002,1002,2002,4002,'Spotify Premium',9.99,'Monthly','2024-10-20',3001,NULL,'2024-01-01'),
 (5003,1003,2003,4003,'Amazon Prime',119.99,'Yearly','2025-01-05',3001,NULL,'2024-01-01'),
 (5004,1004,2004,4004,'Hulu',14.99,'Monthly','2024-10-25',3001,NULL,'2024-01-01'),
 (5005,1005,2005,4005,'Disney+ Bundle',18.99,'Monthly','2024-10-28',3001,NULL,'2024-01-01'),
 (5006,1006,2006,4006,'HBO Max',15.99,'Monthly','2024-10-12',3001,NULL,'2024-01-01'),
 (5007,1007,2007,4007,'YouTube Premium',11.99,'Monthly','2024-10-30',3001,NULL,'2024-01-01');
INSERT INTO CreditCardPayment (PaymentMethodID,CardNumberLast4,ExpirationDate,CardType) VALUES
 (4001,'1234','2025-10-01','Visa'),(4002,'5678','2024-05-01','MasterCard'),
 (4004,'4321','2026-08-01','Amex'),(4006,'8765','2023-12-01','Visa');
INSERT INTO DigitalWalletPayment (PaymentMethodID,WalletProvider,WalletID) VALUES
 (4003,'PayPal','paypal_user_1'),(4005,'Google Pay','gpay_user_5'),(4007,'Apple Pay','apple_user_7');
INSERT INTO Payment (PaymentID,SubscriptionID,PaymentDate,AmountPaid,PaymentMethodID) VALUES
 (6001,5001,'2024-10-01',12.99,4001),(6002,5002,'2024-10-01',9.99,4002),
 (6003,5003,'2024-09-05',119.99,4003),(6004,5004,'2024-09-25',14.99,4004),
 (6005,5005,'2024-09-28',18.99,4005),(6006,5006,'2024-10-12',15.99,4006),
 (6007,5007,'2024-10-01',11.99,4007);
-- Notification subtype rows now agree with their parent type; source had mismatches.
INSERT INTO Notification (NotificationID,AccountID,SubscriptionID,NotificationDate,NextBillingDate,NotificationType) VALUES
 (7001,1001,5001,'2024-10-10','2024-10-15','Email'),
 (7002,1002,5002,'2024-10-15','2024-10-20','SMS'),
 (7003,1003,5003,'2024-12-30','2025-01-05','Email'),
 (7004,1004,5004,'2024-10-20','2024-10-25','SMS'),
 (7005,1005,5005,'2024-10-23','2024-10-28','Email'),
 (7006,1006,5006,'2024-10-07','2024-10-12','Email'),
 (7007,1007,5007,'2024-10-25','2024-10-30','SMS');
INSERT INTO EmailNotification(NotificationID,EmailAddress,AccountID,SubscriptionID,NotificationContent,NotificationDate) VALUES
 (7001,'user1@example.com',1001,5001,'Your Netflix subscription will renew on 2024-10-15.','2024-10-10'),
 (7003,'user3@example.com',1003,5003,'Your Amazon Prime subscription will renew on 2025-01-05.','2024-12-30'),
 (7005,'user5@example.com',1005,5005,'Your Disney+ subscription will renew on 2024-10-28.','2024-10-23'),
 (7006,'user6@example.com',1006,5006,'Your HBO Max subscription will renew on 2024-10-12.','2024-10-07');
INSERT INTO SMSNotification(NotificationID,PhoneNumber,AccountID,SubscriptionID,NotificationContent,NotificationDate) VALUES
 (7002,'+12345678902',1002,5002,'Reminder: Spotify subscription will renew on 2024-10-20.','2024-10-15'),
 (7004,'+12345678904',1004,5004,'Reminder: Hulu subscription will renew on 2024-10-25.','2024-10-20'),
 (7007,'+12345678907',1007,5007,'Reminder: YouTube Premium subscription will renew on 2024-10-30.','2024-10-25');
INSERT INTO AccountPaymentMethod (AccountID,PaymentMethodID) VALUES
 (1001,4001),(1002,4002),(1003,4003),(1004,4004),(1005,4005),(1006,4006),(1007,4007);

CREATE VIEW UpcomingRenewals AS
SELECT a.AccountID,a.AccountUsername,s.SubscriptionID,s.SubscriptionName,
 s.NextBillingDate,s.Cost,pm.MethodType,
 (SELECT COUNT(*) FROM Payment p WHERE p.SubscriptionID=s.SubscriptionID) AS TotalPayments,
 (SELECT MIN(n.NotificationDate) FROM Notification n WHERE n.SubscriptionID=s.SubscriptionID) AS FirstNotificationDate
FROM Account a
JOIN Subscription s ON a.AccountID=s.AccountID
LEFT JOIN PaymentMethod pm ON s.PaymentMethodID=pm.PaymentMethodID
JOIN `Status` st ON s.StatusID=st.StatusID
WHERE st.StatusName='Active'
 AND s.NextBillingDate >= CURRENT_DATE()
 AND s.NextBillingDate < DATE_ADD(CURRENT_DATE(), INTERVAL 1 MONTH);

SELECT (SELECT COUNT(*) FROM Account) AS accounts,
       (SELECT COUNT(*) FROM Subscription) AS subscriptions,
       (SELECT COUNT(*) FROM Payment) AS payments,
       (SELECT COUNT(*) FROM Notification) AS notifications;
