CREATE TABLE emp (
    emp_id      SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    department  VARCHAR(50),
    salary      NUMERIC(10, 2),
    hire_date   DATE DEFAULT CURRENT_DATE
);
