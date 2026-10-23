
USE subscription_portfolio;
DROP TRIGGER IF EXISTS NextBillingDateChangeTrigger;
DROP PROCEDURE IF EXISTS AddUserAccount;
DROP PROCEDURE IF EXISTS AddSubscription;
DROP PROCEDURE IF EXISTS UpdatePaymentMethod;
DROP PROCEDURE IF EXISTS CancelSubscription;
DROP PROCEDURE IF EXISTS AddNotification;
DROP PROCEDURE IF EXISTS ViewUpcomingPayments;

DELIMITER $$

CREATE PROCEDURE AddUserAccount(
 IN p_AccountUsername VARCHAR(64), IN p_EncryptedPassword VARCHAR(255),
 IN p_Email VARCHAR(255), IN p_PhoneNumber VARCHAR(20),
 IN p_FirstName VARCHAR(255), IN p_LastName VARCHAR(255), IN p_DateOfBirth DATE,
 IN p_AddressLine1 VARCHAR(255), IN p_AddressLine2 VARCHAR(255),
 IN p_City VARCHAR(255), IN p_State VARCHAR(255), IN p_PostalCode VARCHAR(20),
 IN p_Country VARCHAR(255), IN p_PaymentMethodID BIGINT
)
BEGIN
 DECLARE v_account_id BIGINT;
 DECLARE v_method_owner BIGINT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 START TRANSACTION;

 INSERT INTO Account(AccountUsername,EncryptedPassword,Email,PhoneNumber,CreatedOn,AccountType)
 VALUES(p_AccountUsername,p_EncryptedPassword,p_Email,p_PhoneNumber,CURRENT_DATE(),'U');
 SET v_account_id = LAST_INSERT_ID();
 INSERT INTO UserProfile(AccountID,FirstName,LastName,DateOfBirth,AddressLine1,AddressLine2,City,State,PostalCode,Country)
 VALUES(v_account_id,p_FirstName,p_LastName,p_DateOfBirth,p_AddressLine1,p_AddressLine2,p_City,p_State,p_PostalCode,p_Country);
 IF p_PaymentMethodID IS NOT NULL THEN
   SELECT MAX(AccountID) INTO v_method_owner FROM PaymentMethod WHERE PaymentMethodID=p_PaymentMethodID;
   IF v_method_owner IS NULL OR v_method_owner <> v_account_id THEN
     SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Payment method must belong to the newly created account';
   END IF;
   INSERT INTO AccountPaymentMethod(AccountID,PaymentMethodID) VALUES(v_account_id,p_PaymentMethodID);
 END IF;
 COMMIT;
END$$

CREATE PROCEDURE AddSubscription(
 IN p_AccountID BIGINT, IN p_ServiceProviderID BIGINT,
 IN p_SubscriptionName VARCHAR(50), IN p_Cost DECIMAL(7,2),
 IN p_BillingFrequency VARCHAR(50), IN p_NextBillingDate DATE,
 IN p_PaymentMethodType VARCHAR(50), IN p_PaymentMethodDetails VARCHAR(255)
)
BEGIN
 DECLARE v_payment_method_id BIGINT;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 IF p_PaymentMethodType NOT IN ('Credit Card','Digital Wallet') THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Payment type must be Credit Card or Digital Wallet';
 END IF;
 IF p_PaymentMethodDetails IS NULL OR TRIM(p_PaymentMethodDetails)='' THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Payment method details required';
 END IF;
 START TRANSACTION;
 INSERT INTO PaymentMethod(AccountID,MethodType) VALUES(p_AccountID,p_PaymentMethodType);
 SET v_payment_method_id=LAST_INSERT_ID();
 IF p_PaymentMethodType='Credit Card' THEN
   IF CHAR_LENGTH(p_PaymentMethodDetails)<>4 OR p_PaymentMethodDetails NOT REGEXP '^[0-9]{4}$' THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='For demo credit cards supply only four digits';
   END IF;
   INSERT INTO CreditCardPayment(PaymentMethodID,CardNumberLast4,ExpirationDate,CardType)
   VALUES(v_payment_method_id,p_PaymentMethodDetails,'2030-10-01','Visa');
 ELSE
   INSERT INTO DigitalWalletPayment(PaymentMethodID,WalletProvider,WalletID)
   VALUES(v_payment_method_id,'PayPal',p_PaymentMethodDetails);
 END IF;
 INSERT INTO Subscription(AccountID,ServiceProviderID,PaymentMethodID,SubscriptionName,Cost,BillingFrequency,NextBillingDate,StatusID)
 VALUES(p_AccountID,p_ServiceProviderID,v_payment_method_id,p_SubscriptionName,p_Cost,p_BillingFrequency,p_NextBillingDate,3001);
 INSERT INTO AccountPaymentMethod(AccountID,PaymentMethodID) VALUES(p_AccountID,v_payment_method_id);
 COMMIT;
END$$

CREATE PROCEDURE UpdatePaymentMethod(IN p_PaymentMethodID BIGINT, IN p_MethodType VARCHAR(50))
BEGIN
.
 IF NOT EXISTS (SELECT 1 FROM PaymentMethod WHERE PaymentMethodID=p_PaymentMethodID) THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Payment method not found';
 ELSEIF (SELECT MethodType FROM PaymentMethod WHERE PaymentMethodID=p_PaymentMethodID) <> p_MethodType THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Changing payment type requires migrating card/wallet details';
 END IF;
END$$

CREATE PROCEDURE CancelSubscription(IN p_SubscriptionID BIGINT, IN p_CancellationDate DATE)
BEGIN
 UPDATE Subscription SET StatusID=3003, CancellationDate=p_CancellationDate WHERE SubscriptionID=p_SubscriptionID;
 IF ROW_COUNT()=0 THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Subscription not found or unchanged'; END IF;
END$$

CREATE PROCEDURE AddNotification(
 IN p_AccountID BIGINT, IN p_SubscriptionID BIGINT,
 IN p_NotificationType VARCHAR(10), IN p_NotificationContent TEXT,
 IN p_NotificationDate DATE, IN p_EmailAddress VARCHAR(255), IN p_PhoneNumber VARCHAR(20)
)
BEGIN
 DECLARE v_notification_id BIGINT;
 DECLARE v_billing_date DATE;
 DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; RESIGNAL; END;
 IF p_NotificationType NOT IN ('Email','SMS') THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Invalid notification type';
 END IF;
 IF p_NotificationType='Email' AND (p_EmailAddress IS NULL OR TRIM(p_EmailAddress)='') THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Email address required';
 END IF;
 IF p_NotificationType='SMS' AND (p_PhoneNumber IS NULL OR TRIM(p_PhoneNumber)='') THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Phone number required';
 END IF;
 SELECT MAX(NextBillingDate) INTO v_billing_date
 FROM Subscription WHERE SubscriptionID=p_SubscriptionID AND AccountID=p_AccountID;
 IF v_billing_date IS NULL THEN
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Subscription/account not found or billing date missing';
 END IF;
 START TRANSACTION;
 INSERT INTO Notification(AccountID,SubscriptionID,NotificationDate,NextBillingDate,NotificationType)
 VALUES(p_AccountID,p_SubscriptionID,p_NotificationDate,v_billing_date,p_NotificationType);
 SET v_notification_id=LAST_INSERT_ID();
 IF p_NotificationType='Email' THEN
   INSERT INTO EmailNotification(NotificationID,AccountID,SubscriptionID,EmailAddress,NotificationContent,NotificationDate)
   VALUES(v_notification_id,p_AccountID,p_SubscriptionID,p_EmailAddress,p_NotificationContent,p_NotificationDate);
 ELSE
   INSERT INTO SMSNotification(NotificationID,AccountID,SubscriptionID,PhoneNumber,NotificationContent,NotificationDate)
   VALUES(v_notification_id,p_AccountID,p_SubscriptionID,p_PhoneNumber,p_NotificationContent,p_NotificationDate);
 END IF;
 COMMIT;
END$$

CREATE PROCEDURE ViewUpcomingPayments(IN p_AccountID BIGINT)
BEGIN
 SELECT * FROM UpcomingRenewals WHERE AccountID=p_AccountID ORDER BY NextBillingDate;
END$$

CREATE TRIGGER NextBillingDateChangeTrigger AFTER UPDATE ON Subscription FOR EACH ROW
BEGIN
 IF NOT (OLD.NextBillingDate <=> NEW.NextBillingDate) THEN
  INSERT INTO SubscriptionHistory(SubscriptionID,AccountID,OldNextBillingDate,NewNextBillingDate,ChangeDate)
  VALUES(NEW.SubscriptionID,NEW.AccountID,OLD.NextBillingDate,NEW.NextBillingDate,CURRENT_DATE());
 END IF;
END$$
DELIMITER ;
