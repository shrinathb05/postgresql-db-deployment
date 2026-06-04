-- execute2.sql
-- Insert a new client
INSERT INTO clients (company_name, plan_type, status) 
VALUES ('New Hosting Client', 'ultra', 'pending') 
RETURNING client_id;

-- Log the action
INSERT INTO deployment_logs (client_id, action_performed)
SELECT client_id, 'New account provisioned' 
FROM clients WHERE company_name = 'New Hosting Client';

-- Show final state of the database
SELECT 'FINAL CLIENT LIST' AS report;
SELECT client_id, company_name, plan_type, status FROM clients ORDER BY client_id DESC;