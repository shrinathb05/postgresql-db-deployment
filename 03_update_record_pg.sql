UPDATE customer_records
SET status = 'ACTIVE',
    balance = balance + 100.00,
    updated_at = CURRENT_TIMESTAMP
WHERE email = 'rajesh@example.com';

SELECT id, username, status, balance, updated_at FROM customer_records WHERE email = 'rajesh@example.com';