create database sq;
use sq;

Create table Emp(
EmployeeID INT PRIMARY KEY,
EmployeeName VARCHAR(100),
Department VARCHAR(50),
Salary DECIMAL(10,2),
ManagerID INT,
HireDate DATE
);

INSERT INTO Emp
(EmployeeID, EmployeeName, Department, Salary, ManagerID, HireDate)
VALUES
(101, 'John', 'Sales', 50000, 201, '2021-01-10'),
(102, 'Mary', 'Sales', 65000, 201, '2020-03-15'),
(103, 'David', 'HR', 55000, 202, '2022-05-20'),
(104, 'Sophia', 'HR', 70000, 202, '2019-07-18'),
(105, 'James', 'IT', 80000, 203, '2018-11-01'),
(106, 'Emma', 'IT', 75000, 203, '2021-09-25'),
(107, 'Michael', 'Finance', 90000, 204, '2017-06-12'),
(108, 'Olivia', 'Finance', 60000, 204, '2023-02-01');

-- Assignment Questions
-- 1. Find employees earning more than the average salary

select * from Emp 
where Salary >  (
select AVG(Salary) as avg_sal from Emp 
);

-- 2. Find employees earning the highest salary.

select * from Emp 
where Salary = (
select MAX(Salary) as highest_sal from Emp 
);

-- 3. Find employees earning the second highest salary
select * from Emp 
where Salary = (select MAX(Salary) 
from emp 
where salary < 
(select max(salary)  from Emp)
);

-- 4. List employees whose salary is less than the maximum salary
select * from Emp 
where Salary < (
select MAX(Salary) from Emp 
);

-- 5. Find employees working in the same department as the employee with the highest salary
select * 
from Emp 
where  Department = (
	select Department 
    from Emp 
	where  Salary=  (
select MAX(Salary)  from Emp )
);

-- 6. Find departments having employees with salary greater than 70,000

select Distinct Department 
from emp where department in 
(select Department
from Emp
where Salary > 70000);

-- 7. Find employees whose salary is above their department average salary
SELECT *
FROM Emp e
WHERE Salary >
(
    SELECT AVG(Salary)
    FROM Emp
    WHERE Department = e.Department
);

-- 8. Find employees who earn more than all employees in the HR department
SELECT *
FROM Emp
WHERE Salary >
ALL
(
    SELECT Salary
    FROM Emp
    WHERE Department = 'HR'
);

-- 9. Find employees whose salary matches any salary in the Sales department
SELECT *
FROM Emp
WHERE Salary = ANY
(
    SELECT Salary
    FROM Emp
    WHERE Department = 'Sales'
);
select * from emp where Department = 'Sales';

select * from emp;

-- 10. Find employees hired after the employee with the lowest salary
select * from emp 
where HireDate > (
select HireDate from emp where salary = (
select min(salary) from emp)
);

-- 11 11. Find the department with the highest average salary

SELECT Department
FROM
(
    SELECT Department,
           AVG(Salary) AS AvgSalary
    FROM Emp
    GROUP BY Department
) AS DeptAvg
WHERE AvgSalary =
(
    SELECT MAX(AvgSalary)
    FROM
    (
        SELECT AVG(Salary) AS AvgSalary
        FROM Emp
        GROUP BY Department
    ) AS X
);

-- 12. Find employees who earn the minimum salary in their department
SELECT *
FROM Emp e
WHERE Salary =
(
    SELECT MIN(Salary)
    FROM Emp
    WHERE Department = e.Department
);

-- 13. Display managers who manage employees earning more than 75,000
SELECT DISTINCT ManagerID
FROM Emp
WHERE Salary > 75000;

-- 14. Find employees whose salary is greater than their manager's salary

SELECT e.EmployeeName,
       e.Salary AS EmployeeSalary,
       m.EmployeeName AS ManagerName,
       m.Salary AS ManagerSalary
FROM Emp e
JOIN Emp m
ON e.ManagerID = m.EmployeeID
WHERE e.Salary > m.Salary;

-- 15 Find the Top 3 highest paid employees using a subquery

SELECT *
FROM Emp e1
WHERE 3 >
(
    SELECT COUNT(DISTINCT Salary)
    FROM Emp e2
    WHERE e2.Salary > e1.Salary
);