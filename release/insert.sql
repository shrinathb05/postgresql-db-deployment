INSERT INTO clients (company_name, plan_type, status)
VALUES ('zoho', 'ultra', 'completed')
RETURNING client_id;
