DELETE FROM customer_records
WHERE status = 'INACTIVE' AND email = 'temp@example.com';

SELECT * FROM customer_records;