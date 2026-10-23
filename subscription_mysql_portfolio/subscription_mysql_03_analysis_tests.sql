
USE subscription_portfolio;

SELECT a.AccountID,a.AccountUsername,s.SubscriptionName,sp.ServiceProviderName,
 pm.MethodType,SUM(p.AmountPaid) AS TotalPayments
FROM Account a
JOIN Subscription s ON a.AccountID=s.AccountID
JOIN Payment p ON s.SubscriptionID=p.SubscriptionID
JOIN ServiceProvider sp ON s.ServiceProviderID=sp.ServiceProviderID
LEFT JOIN PaymentMethod pm ON p.PaymentMethodID=pm.PaymentMethodID
GROUP BY a.AccountID,a.AccountUsername,s.SubscriptionID,s.SubscriptionName,sp.ServiceProviderName,pm.MethodType
HAVING SUM(p.AmountPaid)>0;

SELECT a.AccountID,a.AccountUsername,s.SubscriptionName,
 CASE WHEN cc.PaymentMethodID IS NOT NULL THEN CONCAT('Credit Card (last 4: ',cc.CardNumberLast4,')')
      WHEN dw.PaymentMethodID IS NOT NULL THEN CONCAT('Digital Wallet (',dw.WalletProvider,')')
      ELSE 'Unknown' END AS PaymentDetails
FROM Account a JOIN Subscription s ON s.AccountID=a.AccountID
LEFT JOIN PaymentMethod pm ON s.PaymentMethodID=pm.PaymentMethodID
LEFT JOIN CreditCardPayment cc ON pm.PaymentMethodID=cc.PaymentMethodID
LEFT JOIN DigitalWalletPayment dw ON pm.PaymentMethodID=dw.PaymentMethodID;

SELECT AccountID,AccountUsername,COUNT(*) AS TotalSubscriptionsDue,SUM(Cost) AS TotalCost,
 MethodType,MIN(NextBillingDate) AS EarliestBillingDate,MIN(FirstNotificationDate) AS FirstNotificationDate
FROM UpcomingRenewals
GROUP BY AccountID,AccountUsername,MethodType
ORDER BY EarliestBillingDate;

SELECT a.AccountID,a.AccountUsername,COUNT(s.SubscriptionID) AS ActiveSubscriptions,
 COALESCE(SUM(s.Cost),0) AS SumOfListedSubscriptionCosts
FROM Account a LEFT JOIN Subscription s ON a.AccountID=s.AccountID AND s.StatusID=3001
GROUP BY a.AccountID,a.AccountUsername;

SELECT a.AccountID,a.AccountUsername,n.NotificationType,n.NotificationDate,s.SubscriptionName
FROM Notification n
JOIN Account a ON n.AccountID=a.AccountID
JOIN Subscription s ON n.SubscriptionID=s.SubscriptionID
ORDER BY n.NotificationDate;

SELECT MethodType,COUNT(*) AS MethodCount FROM PaymentMethod GROUP BY MethodType;
-- Bar chart dataset: actual recorded payments per account.
SELECT a.AccountUsername,SUM(p.AmountPaid) AS TotalPayments
FROM Account a JOIN Subscription s ON a.AccountID=s.AccountID
JOIN Payment p ON s.SubscriptionID=p.SubscriptionID
GROUP BY a.AccountID,a.AccountUsername;

SELECT (SELECT COUNT(*) FROM Account) AS Accounts,
(SELECT COUNT(*) FROM Subscription) AS Subscriptions,
(SELECT COUNT(*) FROM Payment) AS Payments,
(SELECT COUNT(*) FROM Notification) AS Notifications;

SELECT COUNT(*) AS MisclassifiedNotifications
FROM Notification n
LEFT JOIN EmailNotification e ON n.NotificationID=e.NotificationID
LEFT JOIN SMSNotification t ON n.NotificationID=t.NotificationID
WHERE (n.NotificationType='Email' AND (e.NotificationID IS NULL OR t.NotificationID IS NOT NULL))
   OR (n.NotificationType='SMS' AND (t.NotificationID IS NULL OR e.NotificationID IS NOT NULL));
