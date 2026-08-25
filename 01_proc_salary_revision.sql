-- 1. Create or Replace Procedure
CREATE OR REPLACE PROCEDURE sp_apply_salary_revision(
    p_department VARCHAR(50),
    p_percentage NUMERIC(5, 2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_updated_rows INT := 0;
    v_min_salary NUMERIC(10, 2);
    v_max_salary NUMERIC(10, 2);
BEGIN
    -- Input Validation
    IF p_percentage <= 0 OR p_percentage > 50 THEN
        RAISE EXCEPTION 'Invalid increment percentage: %. Must be between 0.01 and 50.00', p_percentage;
    END IF;

    -- Update Employee Salaries
    UPDATE employee
    SET salary = ROUND(salary + (salary * (p_percentage / 100)), 2),
        updated_at = CURRENT_TIMESTAMP
    WHERE department = p_department
      AND status = 'ACTIVE';

    GET DIAGNOSTICS v_updated_rows = ROW_COUNT;

    IF v_updated_rows = 0 THEN
        RAISE NOTICE 'No active employees found in department: %', p_department;
    ELSE
        -- Query min and max for summary reporting
        SELECT MIN(salary), MAX(salary)
        INTO v_min_salary, v_max_salary
        FROM employee
        WHERE department = p_department;

        RAISE NOTICE 'Salary Revision Applied Successfully!';
        RAISE NOTICE 'Department: %, Updated Rows: %, Min Salary: %, Max Salary: %',
            p_department, v_updated_rows, v_min_salary, v_max_salary;
    END IF;
END;
$$;

-- 2. Test Execution
CALL sp_apply_salary_revision('DevOps', 10.00);

-- 3. Verification Query
SELECT emp_id, first_name, last_name, department, salary, updated_at 
FROM employee 
WHERE department = 'DevOps';