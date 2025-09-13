/*Write a query to display the tomorrow’s date in the following format:

    September 16th of year 2022

the result will depend on the day when you RUN/EXECUTE this query. 

Label the column Tomorrow.*/

SELECT TO_CHAR(current_date+1, 'fm Month ddth "of year" YYYY' ) AS "Tomorrow" 
    FROM dual;
    
/*
    Write a query that displays the full name and job title of the manager for employees whose job title is "Finance Manager" in the following format:

Jude Rivera works as Administration Vice President.

The query returns 1 row.

Sort the result based on employee ID.
    
*/

-- Answer


SELECT emp2.first_name || ' ' || emp2.last_name|| ' works as '|| emp2.job_title 
FROM employees emp1 
inner join employees emp2
on emp1.manager_id = emp2.employee_id
WHERE emp1.job_title = 'Finance Manager'
ORDER BY emp1.employee_id;

/*
For employees hired in November 2016, display the employee’s last name, hire date and calculate the number of months between the current date and the date the employee was hired, considering that if an employee worked over half of a month, it should be counted as one month.

Label the column Months Worked.
The query returns 5 rows.
*/

SELECT last_name, hire_date, round(months_between(current_date,hire_date)) as "Month Worked"
FROM employees
WHERE hire_date BETWEEN '01-NOV-16' AND '30-NOV-16'
ORDER BY hire_date, last_name;


/*
Display each employee’s last name, hire date, and the review date, which is the first Friday after five months of service. Show the result only for those hired before January 20, 2016. 

Label the column REVIEW DATE. 
Format the dates to appear in the format like:
TUESDAY, January the Thirty-First of year 2016
You can use ddspth to have the above format for the day.
Sort first by review date and then by last name.
The query returns 6 rows.
*/

SELECT last_name,hire_date, next_day(add_months(hire_date,5), 'Friday') as "REVIEW DATE"
FROM employees
WHERE hire_date < to_date('20-01-16','DD-MM-YY')
ORDER BY "REVIEW DATE", last_name;

/*
For all warehouses, display warehouse id, warehouse name, city, and state. For warehouses with the null value for the state column, display “unknown”. Sort the result based on the warehouse ID.

The query returns 9 rows.
*/

SELECT wh.warehouse_id,wh.warehouse_name,lo.city, nvl(lo.state,'unknown')AS "STATE"
FROM warehouses wh  JOIN locations lo
ON wh.location_id = lo.location_id
ORDER BY wh.warehouse_id;  