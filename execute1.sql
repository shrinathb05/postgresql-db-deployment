-- execute1.sql
-- Add a status column to the clients table
ALTER TABLE clients ADD COLUMN status VARCHAR(20) DEFAULT 'active';

-- Create a secondary table for logs
CREATE TABLE deployment_logs (
    log_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES clients(client_id),
    action_performed TEXT,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

SELECT 'SCHEMA UPDATE: Column and Log table created' AS info;