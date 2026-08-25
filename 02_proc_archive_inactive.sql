-- 1. Create Archive Table If Not Exists
CREATE TABLE IF NOT EXISTS employee_archive (
    archive_id SERIAL PRIMARY KEY,
    emp_id INT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    department VARCHAR(50),
    designation VARCHAR(50),
    salary NUMERIC(10, 2),
    hire_date DATE,
    archived_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    archive_reason VARCHAR(255)
);

-- 2. Create Archival Procedure
CREATE OR REPLACE PROCEDURE sp_archive_inactive_employees(
    p_reason VARCHAR(255) DEFAULT 'Scheduled Inactive User Archival'
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_archived_count INT := 0;
BEGIN
    -- Copy inactive employees into archive
    INSERT INTO employee_archive (
        emp_id, first_name, last_name, email, department, designation, salary, hire_date, archive_reason
    )
    SELECT emp_id, first_name, last_name, email, department, designation, salary, hire_date, p_reason
    FROM employee
    WHERE status = 'INACTIVE';

    GET DIAGNOSTICS v_archived_count = ROW_COUNT;

    -- Delete archived records from primary table
    IF v_archived_count > 0 THEN
        DELETE FROM employee
        WHERE status = 'INACTIVE';

        RAISE NOTICE 'Successfully archived and purged % inactive employee records.', v_archived_count;
    ELSE
        RAISE NOTICE 'No inactive employee records found for archival.';
    END IF;
END;
$$;

-- 3. Test Execution
CALL sp_archive_inactive_employees('Q3 Maintenance Datafix');

-- 4. Verification Queries
SELECT * FROM employee_archive;
SELECT emp_id, first_name, last_name, status FROM employee;