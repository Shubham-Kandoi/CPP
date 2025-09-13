SET SERVEROUTPUT ON;

--1 
CREATE OR REPLACE FUNCTION my_median(p_table_name IN VARCHAR2, p_column_name IN VARCHAR2)
RETURN NUMBER
IS
    v_count   NUMBER;
    v_median  NUMBER;
    v_sql     VARCHAR2(1000);
BEGIN
    -- Step 1: Count total number of non-null elements
    v_sql := 'SELECT COUNT(' || p_column_name || ') FROM ' || p_table_name || 
             ' WHERE ' || p_column_name || ' IS NOT NULL';

    EXECUTE IMMEDIATE v_sql INTO v_count;

    -- Step 2: If empty, return NULL
    IF v_count = 0 THEN
        RETURN NULL;
    END IF;

    -- Step 3: If odd, return middle value
    IF MOD(v_count, 2) = 1 THEN
        v_sql := '
            SELECT ' || p_column_name || ' FROM (
                SELECT ' || p_column_name || ', ROW_NUMBER() OVER (ORDER BY ' || p_column_name || ') AS rn
                FROM ' || p_table_name || '
                WHERE ' || p_column_name || ' IS NOT NULL
            ) WHERE rn = ' || TO_CHAR((v_count + 1)/2);

        EXECUTE IMMEDIATE v_sql INTO v_median;

    -- Step 4: If even, return average of two middle values
    ELSE
        v_sql := '
            SELECT AVG(val) FROM (
                SELECT ' || p_column_name || ' AS val, ROW_NUMBER() OVER (ORDER BY ' || p_column_name || ') AS rn
                FROM ' || p_table_name || '
                WHERE ' || p_column_name || ' IS NOT NULL
            )
            WHERE rn IN (' || TO_CHAR(v_count/2) || ', ' || TO_CHAR(v_count/2 + 1) || ')';

        EXECUTE IMMEDIATE v_sql INTO v_median;
    END IF;

    RETURN v_median;
END;
/

-- Call 1
SELECT my_median('EMPLOYEE', 'SALARY') AS Median_Even FROM dual;

-- Call 2
SELECT my_median('STAFF', 'SALARY') AS Median_Odd FROM dual;

-- Call 3

SELECT my_median('TESTING', 'SALARY') AS Median_Empty FROM dual; -- I have created a empty Table(Testing) 

-- Function 2:

CREATE OR REPLACE FUNCTION my_mode(p_table_name IN VARCHAR2, p_column_name IN VARCHAR2)
RETURN VARCHAR2
IS
    v_result VARCHAR2(1000);
BEGIN
    -- Use dynamic SQL to return the most frequent value(s)
    EXECUTE IMMEDIATE '
        SELECT LISTAGG(' || p_column_name || ', '', '') WITHIN GROUP (ORDER BY ' || p_column_name || ')
        FROM (
            SELECT ' || p_column_name || '
            FROM (
                SELECT ' || p_column_name || ', COUNT(*) AS freq
                FROM ' || p_table_name || '
                WHERE ' || p_column_name || ' IS NOT NULL
                GROUP BY ' || p_column_name || '
            )
            WHERE freq = (
                SELECT MAX(freq) FROM (
                    SELECT COUNT(*) AS freq
                    FROM ' || p_table_name || '
                    WHERE ' || p_column_name || ' IS NOT NULL
                    GROUP BY ' || p_column_name || '
                )
            )
        )'
    INTO v_result;

    RETURN v_result;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'No mode';
    WHEN OTHERS THEN
        RETURN 'Error: ' || SQLERRM;
END;
/



-- Call 1: A list with zero modes

SELECT my_mode('Staff', 'ID') AS Zero_Mode FROM dual; -- No mode, Id is a unique value so it prints all the value


-- Call 2: A list with one mode

SELECT my_mode('EMPLOYEE', 'WORKDEPT') AS One_Mode FROM dual; -- It prints a D11

-- Call 3:A list with two modes

SELECT my_mode('STAFF', 'JOB') AS Multiple_Mode FROM dual; -- It prints Clerk, Sales

-- Call 4: An empty list

SELECT my_mode('Testing', 'Salary') AS Empty_Mode FROM dual; -- It prints nothing (null)

-- Function 3

CREATE OR REPLACE PROCEDURE my_math_all_salary(p_table_name IN VARCHAR2)
IS
    v_median NUMBER;
    v_mode   VARCHAR2(100);
    v_mean   NUMBER;
BEGIN
    v_median := my_median_salary(p_table_name);
    v_mode   := my_mode(p_table_name, 'WORKDEPT');  -- or DEPT for STAFF

    EXECUTE IMMEDIATE 'SELECT AVG(salary) FROM ' || p_table_name || ' WHERE salary IS NOT NULL'
    INTO v_mean;

    DBMS_OUTPUT.PUT_LINE('Median: ' || v_median);
    DBMS_OUTPUT.PUT_LINE('Mode: ' || v_mode);
    DBMS_OUTPUT.PUT_LINE('Mean : ' || v_mean);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- CALL 1:
BEGIN
    my_math_all_salary('EMPLOYEE');
END;

-- Call 2: 
BEGIN
    my_math_all_salary('Testing');
END;
/




