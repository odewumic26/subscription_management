-- Run in DBeaver against your existing MySQL instance.
SELECT 'Account' AS table_name, COUNT(*) AS rows_count FROM subscription_portfolio.Account
UNION ALL SELECT 'Subscription',COUNT(*) FROM subscription_portfolio.Subscription
UNION ALL SELECT 'Payment',COUNT(*) FROM subscription_portfolio.Payment
UNION ALL SELECT 'Notification',COUNT(*) FROM subscription_portfolio.Notification;

-- Revenue by calendar month (based on actual recorded payments in this demo).
SELECT DATE_FORMAT(PaymentDate, '%Y-%m') AS payment_month,
       COUNT(*) AS payment_count,
       ROUND(SUM(AmountPaid),2) AS revenue_usd
FROM subscription_portfolio.Payment
GROUP BY DATE_FORMAT(PaymentDate, '%Y-%m')
ORDER BY payment_month;

-- Check for orphan payments (should be zero).
SELECT COUNT(*) AS orphan_payments
FROM subscription_portfolio.Payment p
LEFT JOIN subscription_portfolio.Subscription s ON p.SubscriptionID=s.SubscriptionID
WHERE s.SubscriptionID IS NULL;
