USE employees_mod

SELECT * FROM t_departments
SELECT * FROM dept_emp
SELECT * FROM t_dept_manager
SELECT * FROM t_employees
SELECT * FROM t_salaries

/* Chart 1. Create a visualization that provides a breakdown between 
the male and female employees working in the company each year,
starting from 1990. */

SELECT
	YEAR(de.from_date) AS calender_year,
    e.gender,
    COUNT(e.emp_no) AS num_of_employees
FROM
	t_dept_emp AS de
	INNER JOIN
	t_employees AS e
    ON de.emp_no = e.emp_no
GROUP BY
	e.gender,
    calender_year
HAVING
	calender_year >= '1990'
ORDER BY
	calender_year ASC

/* Chart 2. Compare the number of male managers to the number of
female managers from different departments for each year,
starting from 1990. */

SELECT
	d.dept_name,
    e.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
	CASE
		WHEN YEAR (dm.to_date) >= e.calendar_year AND YEAR (dm.from_date) <= e.calendar_year THEN 1
        ELSE 0
	END AS active
FROM
	(SELECT
		YEAR(hire_date) AS calendar_year
	FROM
		t_employees
	GROUP BY
		calendar_year) e
	CROSS JOIN
    t_dept_manager dm
    INNER JOIN
    t_departments d
    ON dm.dept_no = d.dept_no
    INNER JOIN
    t_employees e
    ON dm.emp_no = e.emp_no
ORDER BY
	dm.emp_no,
    calendar_year
    
/* Chart 3. Compare the average salary of female versus male employees in
the entire company until year 2002, and add a filter allowing
you to see that per each department. */

SELECT
	 e.gender,
     d.dept_name,
    YEAR (s.from_date) calendar_year,
	ROUND(AVG(s.salary), 2) avg_salary
FROM
	t_employees e
    INNER JOIN
    t_salaries s
    ON e.emp_no = s.emp_no
    INNER JOIN
    t_dept_emp de
    ON e.emp_no = de.emp_no
    INNER JOIN
	t_departments d
    ON de.dept_no = d.dept_no
GROUP BY
	d.dept_no,
    calendar_year,
    e.gender
HAVING
	calendar_year <= 2002
ORDER BY
	d.dept_no
    
/* Chart 4. Create an SQL stored procedure that will allow you to obtain the
average male and female salary per department within a certain
salary range. Let this range be defined by two values the user
can insert when calling the procedure. */

DELIMITER //
CREATE PROCEDURE filter_salary (IN min_salary FLOAT, IN max_salary FLOAT)
BEGIN
SELECT
	e.gender,
    d.dept_name,
    avg(s.salary) as avg_salary
FROM
	t_employees e
    JOIN
	t_dept_emp de
    ON e.emp_no = de.emp_no
    JOIN
    t_salaries s
    ON e.emp_no = s.emp_no
    JOIN
	t_departments d
    ON de.dept_no = d.dept_no
WHERE
	s.salary BETWEEN min_salary AND max_salary
GROUP BY
	e.gender,
    d.dept_name;
END //
DELIMITER ;

CALL filter_salary(50000,90000);