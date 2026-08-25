-- pg_backup.sql
-- Drop table if exists to ensure a clean start for testing
DROP TABLE IF EXISTS clients;

CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    company_name VARCHAR(100) NOT NULL,
    plan_type VARCHAR(20) DEFAULT 'basic',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Initial Seed Data
INSERT INTO clients (company_name, plan_type) VALUES 
('Global Tech Solutions', 'premium'),
('Local Bakery Shop', 'basic');

SELECT 'BACKUP RESTORED SUCCESSFULLY' AS status;
SELECT * FROM clients;