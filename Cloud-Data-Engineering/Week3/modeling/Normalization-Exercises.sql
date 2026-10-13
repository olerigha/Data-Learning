/***********************************************
** Name:        Database Normalization
** Description: Demonstrates UNF → 1NF → 2NF → 3NF using an employee/department dataset
** Author:      Ashish Pujari
************************************************/

-- =================================================================
-- UNNORMALIZED FORM (UNF)
-- A single flat table with repeating groups and multi-valued columns.
-- Problems: data redundancy, anomalies on insert/update/delete.
-- =================================================================
CREATE TABLE employees_unnorm (
    emp_id        INT,
    emp_name      VARCHAR(100),
    dept_id       INT,
    dept_name     VARCHAR(100),
    dept_location VARCHAR(100),
    project_ids   VARCHAR(200),   -- repeating group: 'P1,P2,P3'
    project_names VARCHAR(500),   -- repeating group: 'Alpha,Beta,Gamma'
    skills        VARCHAR(200)    -- multi-valued:    'Python,SQL,Spark'
);

INSERT INTO employees_unnorm VALUES
(1, 'Alice Johnson', 10, 'Engineering', 'San Francisco', 'P1,P2',    'Alpha,Beta',  'Python,SQL'),
(2, 'Bob Smith',     10, 'Engineering', 'San Francisco', 'P2,P3',    'Beta,Gamma',  'Java,Spark'),
(3, 'Carol White',   20, 'Marketing',   'New York',      'P1',       'Alpha',       'SQL'),
(4, 'David Brown',   20, 'Marketing',   'New York',      'P1,P3',    'Alpha,Gamma', 'Python,R');

SELECT * FROM employees_unnorm;
-- Note the redundancy: every Engineering employee repeats dept_name and dept_location.
-- Updating 'San Francisco' requires touching every affected row.


-- =================================================================
-- FIRST NORMAL FORM (1NF)
-- Rule: Every column holds one atomic (indivisible) value.
--       No repeating groups. Each row is uniquely identifiable.
-- =================================================================
-- Solution: expand each (emp, project, skill) combination into its own row.

CREATE TABLE employees_1nf (
    emp_id        INT,
    emp_name      VARCHAR(100),
    dept_id       INT,
    dept_name     VARCHAR(100),
    dept_location VARCHAR(100),
    project_id    VARCHAR(10),
    project_name  VARCHAR(100),
    skill         VARCHAR(50),
    PRIMARY KEY (emp_id, project_id, skill)
);

INSERT INTO employees_1nf VALUES
(1,'Alice Johnson',10,'Engineering','San Francisco','P1','Alpha','Python'),
(1,'Alice Johnson',10,'Engineering','San Francisco','P1','Alpha','SQL'),
(1,'Alice Johnson',10,'Engineering','San Francisco','P2','Beta', 'Python'),
(1,'Alice Johnson',10,'Engineering','San Francisco','P2','Beta', 'SQL'),
(2,'Bob Smith',    10,'Engineering','San Francisco','P2','Beta', 'Java'),
(2,'Bob Smith',    10,'Engineering','San Francisco','P2','Beta', 'Spark'),
(2,'Bob Smith',    10,'Engineering','San Francisco','P3','Gamma','Java'),
(2,'Bob Smith',    10,'Engineering','San Francisco','P3','Gamma','Spark'),
(3,'Carol White',  20,'Marketing',  'New York',     'P1','Alpha','SQL'),
(4,'David Brown',  20,'Marketing',  'New York',     'P1','Alpha','Python'),
(4,'David Brown',  20,'Marketing',  'New York',     'P1','Alpha','R'),
(4,'David Brown',  20,'Marketing',  'New York',     'P3','Gamma','Python'),
(4,'David Brown',  20,'Marketing',  'New York',     'P3','Gamma','R');

-- Still problematic: dept_name/dept_location depend only on dept_id,
-- not on the full composite key (emp_id, project_id, skill). Partial dependency.


-- =================================================================
-- SECOND NORMAL FORM (2NF)
-- Rule: Must be in 1NF AND every non-key column depends on the WHOLE key.
--       Removes PARTIAL DEPENDENCIES.
-- =================================================================

-- departments: dept_name and dept_location depend only on dept_id → own table
CREATE TABLE departments (
    dept_id       INT          PRIMARY KEY,
    dept_name     VARCHAR(100) NOT NULL,
    dept_location VARCHAR(100) NOT NULL
);
INSERT INTO departments VALUES
(10, 'Engineering', 'San Francisco'),
(20, 'Marketing',   'New York');

-- projects: project_name depends only on project_id → own table
CREATE TABLE projects (
    project_id   VARCHAR(10)  PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL
);
INSERT INTO projects VALUES ('P1','Alpha'), ('P2','Beta'), ('P3','Gamma');

-- employees: emp_name depends only on emp_id
CREATE TABLE employees (
    emp_id   INT          PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    dept_id  INT          NOT NULL,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
INSERT INTO employees VALUES
(1,'Alice Johnson',10), (2,'Bob Smith',10), (3,'Carol White',20), (4,'David Brown',20);

-- employee_projects: junction for the many-to-many relationship
CREATE TABLE employee_projects (
    emp_id     INT        NOT NULL,
    project_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (emp_id, project_id),
    FOREIGN KEY (emp_id)     REFERENCES employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);
INSERT INTO employee_projects VALUES
(1,'P1'),(1,'P2'),(2,'P2'),(2,'P3'),(3,'P1'),(4,'P1'),(4,'P3');

-- employee_skills: junction for the many-to-many relationship
CREATE TABLE employee_skills (
    emp_id INT         NOT NULL,
    skill  VARCHAR(50) NOT NULL,
    PRIMARY KEY (emp_id, skill),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);
INSERT INTO employee_skills VALUES
(1,'Python'),(1,'SQL'),(2,'Java'),(2,'Spark'),(3,'SQL'),(4,'Python'),(4,'R');


-- =================================================================
-- THIRD NORMAL FORM (3NF)
-- Rule: Must be in 2NF AND no non-key column depends on another non-key column.
--       Removes TRANSITIVE DEPENDENCIES.
-- =================================================================
-- Example: if we add zip_code to departments, and zip_code → city → state,
-- then dept_id → zip_code → city is a transitive dependency.

CREATE TABLE zip_codes (
    zip_code VARCHAR(10)  PRIMARY KEY,
    city     VARCHAR(100) NOT NULL,
    state    VARCHAR(50)  NOT NULL,
    country  VARCHAR(50)  NOT NULL DEFAULT 'USA'
);
INSERT INTO zip_codes VALUES
('94105', 'San Francisco', 'CA', 'USA'),
('10001', 'New York',       'NY', 'USA');

-- departments_3nf: references zip_code instead of storing city/state directly
CREATE TABLE departments_3nf (
    dept_id   INT          PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    zip_code  VARCHAR(10)  NOT NULL,
    FOREIGN KEY (zip_code) REFERENCES zip_codes(zip_code)
);
INSERT INTO departments_3nf VALUES
(10, 'Engineering', '94105'),
(20, 'Marketing',   '10001');


-- =================================================================
-- EXERCISES
-- =================================================================

-- 1. List all employees with their department name and city (3NF join)
SELECT
    e.emp_id,
    e.emp_name,
    d.dept_name,
    z.city,
    z.state
FROM employees e
JOIN departments_3nf d ON e.dept_id  = d.dept_id
JOIN zip_codes      z  ON d.zip_code = z.zip_code
ORDER BY e.emp_id;

-- 2. List each employee alongside all their assigned projects
SELECT
    e.emp_name,
    GROUP_CONCAT(p.project_name ORDER BY p.project_id) AS projects
FROM employees e
JOIN employee_projects ep ON e.emp_id    = ep.emp_id
JOIN projects          p  ON ep.project_id = p.project_id
GROUP BY e.emp_name
ORDER BY e.emp_name;

-- 3. Find employees who share at least one project with Alice Johnson
SELECT DISTINCT e.emp_name
FROM employees e
JOIN employee_projects ep ON e.emp_id = ep.emp_id
WHERE ep.project_id IN (
    SELECT ep2.project_id
    FROM employees e2
    JOIN employee_projects ep2 ON e2.emp_id = ep2.emp_id
    WHERE e2.emp_name = 'Alice Johnson'
)
AND e.emp_name != 'Alice Johnson'
ORDER BY e.emp_name;

-- 4. Count skills per employee, ordered by most skilled first
SELECT
    e.emp_name,
    COUNT(s.skill) AS skill_count,
    GROUP_CONCAT(s.skill ORDER BY s.skill) AS skills
FROM employees e
JOIN employee_skills s ON e.emp_id = s.emp_id
GROUP BY e.emp_name
ORDER BY skill_count DESC;

-- 5. Which department has the most unique projects assigned across its employees?
SELECT
    d.dept_name,
    COUNT(DISTINCT ep.project_id) AS project_count
FROM departments d
JOIN employees         e  ON d.dept_id  = e.dept_id
JOIN employee_projects ep ON e.emp_id   = ep.emp_id
GROUP BY d.dept_name
ORDER BY project_count DESC;

-- 6. Verify referential integrity: are there orphaned employee_project records?
SELECT ep.*
FROM employee_projects ep
LEFT JOIN employees e ON ep.emp_id = e.emp_id
WHERE e.emp_id IS NULL;    -- should return 0 rows


-- Cleanup
DROP TABLE IF EXISTS employee_skills;
DROP TABLE IF EXISTS employee_projects;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments_3nf;
DROP TABLE IF EXISTS zip_codes;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS employees_1nf;
DROP TABLE IF EXISTS employees_unnorm;

---- END ----
