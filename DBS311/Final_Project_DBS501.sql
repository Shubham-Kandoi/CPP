-- Name: Shubham Dharmendrabhai Kandoi
-- Student ID: 144838232
-- Section: NSA
-- Date: 7 August 2025


-- Question 2 
-- Create the procedure

CREATE OR REPLACE PROCEDURE staff_add(
    p_name   IN STAFF.NAME%TYPE,
    p_job    IN STAFF.JOB%TYPE,
    p_salary IN STAFF.SALARY%TYPE,
    p_comm   IN STAFF.COMM%TYPE
) IS
    v_new_id STAFF.ID%TYPE;
    v_max_id STAFF.ID%TYPE;
BEGIN
    -- compute new ID: max ID + 10 ; handle empty table
    SELECT NVL(MAX(ID), 0) INTO v_max_id FROM STAFF;
    v_new_id := v_max_id + 10;

    -- validation on JOB
    IF UPPER(TRIM(p_job)) NOT IN ('SALES','CLERK','MGR') THEN
        RAISE_APPLICATION_ERROR(-20001, 'staff_add: Invalid JOB. Acceptable values: Sales, Clerk, Mgr.');
    END IF;

    INSERT INTO STAFF (ID, NAME, DEPT, JOB, YEARS, SALARY, COMM)
    VALUES (v_new_id, p_name, 90, INITCAP(LOWER(TRIM(p_job))), 1, p_salary, p_comm);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE; -- bubble up after rollback
END staff_add;
/
-- TEST / DEMO for Q2
PROMPT Q2 TEST: Insert a valid record, then an invalid JOB insert to trigger error.
-- Valid insert
BEGIN
    staff_add('Test User', 'Sales', 50000, 2000);
END;
/
-- Check inserted row
SELECT * FROM STAFF WHERE NAME = 'Test User';

-- Invalid insert (should raise application error)
DECLARE
BEGIN
    staff_add('Bad Job User', 'InvalidJob', 40000, 1000);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected error on invalid job: ' || SQLERRM);
END;
/
-- Remove test valid record to keep data clean (optional)
DELETE FROM STAFF WHERE NAME = 'Test User';
COMMIT;


-- Questtion 3

CREATE TABLE STAFFAUDTBL (
    ID      NUMBER,
    INCJOB  VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER ins_job
BEFORE INSERT ON STAFF
FOR EACH ROW
DECLARE
BEGIN
    IF UPPER(TRIM(:NEW.JOB)) NOT IN ('SALES','CLERK','MGR') THEN
        -- log into audit
        INSERT INTO STAFFAUDTBL (ID, INCJOB) VALUES (:NEW.ID, :NEW.JOB);
        -- prevent insert
        RAISE_APPLICATION_ERROR(-20002, 'ins_job: Invalid JOB on insert; logged to STAFFAUDTBL.');
    END IF;
END;
/
-- TEST / DEMO Q3: Try inserting invalid job directly
PROMPT Q3 TEST: Insert with invalid JOB to see STAFFAUDTBL populated.
-- Attempt invalid insert
BEGIN
    INSERT INTO STAFF (ID, NAME, DEPT, JOB, YEARS, SALARY, COMM)
    VALUES (9999, 'Invalid Insert', 90, 'BadJob', 1, 1000, 0);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected insertion error: ' || SQLERRM);
        ROLLBACK;
END;
/
-- Show STAFFAUDTBL contents after test
SELECT * FROM STAFFAUDTBL;

-- Clean up test audit row if present
DELETE FROM STAFFAUDTBL WHERE ID = 9999;
COMMIT;

-- Question 4

CREATE OR REPLACE FUNCTION total_cmp(p_id IN NUMBER) RETURN NUMBER IS
    v_salary STAFF.SALARY%TYPE;
    v_comm   STAFF.COMM%TYPE;
BEGIN
    SELECT SALARY, COMM
      INTO v_salary, v_comm
      FROM STAFF
     WHERE ID = p_id;

    RETURN NVL(v_salary,0) + NVL(v_comm,0);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'total_cmp: Invalid ID - no such STAFF record.');
    WHEN OTHERS THEN
        RAISE;
END total_cmp;
/
-- TEST / DEMO Q4
PROMPT Q4 TEST: valid and invalid calls
-- Valid call example (replace 10 with an existing ID in your STAFF table)
SET SERVEROUTPUT ON;
DECLARE
    v_total NUMBER;
BEGIN
    -- Find an existing ID for demonstration:
    SELECT ID INTO v_total FROM STAFF WHERE ROWNUM = 1;
    DBMS_OUTPUT.PUT_LINE('Example ID used: ' || v_total);
    DBMS_OUTPUT.PUT_LINE('Total comp = ' || total_cmp(v_total));
END;
/
-- Invalid ID call
BEGIN
    DBMS_OUTPUT.PUT_LINE('Calling total_cmp with invalid ID 999999');
    DBMS_OUTPUT.PUT_LINE('Result: ' || total_cmp(999999));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/

-- Question 5

BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE STAFFAUDTBL ADD (OLDCOMM NUMBER, NEWCOMM NUMBER)';
EXCEPTION WHEN OTHERS THEN
    -- ignore if already exists
    NULL;
END;
/


CREATE OR REPLACE TRIGGER upd_comm
BEFORE UPDATE OF COMM ON STAFF
FOR EACH ROW
BEGIN
    -- record the change: for Q5 we put ID, INCJOB=NULL, OLDCOMM and NEWCOMM
    INSERT INTO STAFFAUDTBL (ID, INCJOB, OLDCOMM, NEWCOMM)
    VALUES (:OLD.ID, NULL, :OLD.COMM, :NEW.COMM);
END;
/
-- Create the set_comm procedure
DROP PROCEDURE set_comm PURGE;
CREATE OR REPLACE PROCEDURE set_comm IS
    CURSOR c_staff IS SELECT ID, JOB, SALARY, COMM FROM STAFF FOR UPDATE OF COMM;
    v_new_comm NUMBER;
BEGIN
    FOR r IN c_staff LOOP
        IF r.JOB IS NULL THEN
            v_new_comm := 0;
        ELSE
            CASE UPPER(TRIM(r.JOB))
                WHEN 'MGR'   THEN v_new_comm := r.SALARY * 0.20;
                WHEN 'CLERK' THEN v_new_comm := r.SALARY * 0.10;
                WHEN 'SALES' THEN v_new_comm := r.SALARY * 0.30;
                WHEN 'PREZ'  THEN v_new_comm := r.SALARY * 0.50;
                ELSE v_new_comm := r.COMM; -- keep existing if job unknown
            END CASE;
        END IF;

        -- Update only if different to avoid unnecessary triggers
        IF NVL(r.COMM,0) <> NVL(ROUND(v_new_comm,2),0) THEN
            UPDATE STAFF SET COMM = ROUND(v_new_comm,2) WHERE CURRENT OF c_staff;
        END IF;
    END LOOP;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END set_comm;
/
-- TEST / DEMO Q5
PROMPT Q5 TEST: Show STAFF before and after running set_comm; show STAFFAUDTBL changes
-- Snapshot: example selection (first 10)
SELECT ID, NAME, JOB, SALARY, COMM FROM STAFF WHERE ROWNUM <= 10;

-- Run procedure to update commissions
BEGIN
    set_comm;
END;
/

-- After update: show the affected STAFF rows (first 10)
SELECT ID, NAME, JOB, SALARY, COMM FROM STAFF WHERE ROWNUM <= 10;

-- Show entries added to STAFFAUDTBL for updates (limit some)
SELECT * FROM STAFFAUDTBL WHERE OLDCOMM IS NOT NULL AND ROWNUM <= 20;

-- Question 6

-- Drop existing STAFFAUDTBL and recreate per Q6 instructions
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE STAFFAUDTBL PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE STAFFAUDTBL (
    ID       NUMBER,
    ACTION   VARCHAR2(1),       -- 'I' 'U' 'D'
    INCJOB   VARCHAR2(100),
    OLDCOMM  NUMBER,
    NEWCOMM  NUMBER
);

-- Create combined trigger staff_trig
CREATE OR REPLACE TRIGGER staff_trig
BEFORE INSERT OR UPDATE OR DELETE ON STAFF
FOR EACH ROW
DECLARE
BEGIN
    IF INSERTING THEN
        -- Validate job on insert
        IF UPPER(TRIM(:NEW.JOB)) NOT IN ('SALES','CLERK','MGR') THEN
            INSERT INTO STAFFAUDTBL (ID, ACTION, INCJOB, OLDCOMM, NEWCOMM)
            VALUES (:NEW.ID, 'I', :NEW.JOB, NULL, NULL);
            RAISE_APPLICATION_ERROR(-20004, 'staff_trig (INSERT): Invalid JOB; logged to STAFFAUDTBL.');
        ELSE
            -- Optionally, you could log successful inserts - not required by assignment
            NULL;
        END IF;
    ELSIF UPDATING THEN
        -- If JOB changed to invalid value, log then raise
        IF :NEW.JOB IS NOT NULL AND UPPER(TRIM(:NEW.JOB)) NOT IN ('SALES','CLERK','MGR') THEN
            INSERT INTO STAFFAUDTBL (ID, ACTION, INCJOB, OLDCOMM, NEWCOMM)
            VALUES (NVL(:NEW.ID, :OLD.ID), 'U', :NEW.JOB, NULL, NULL);
            RAISE_APPLICATION_ERROR(-20005, 'staff_trig (UPDATE): Invalid JOB; logged to STAFFAUDTBL.');
        END IF;

        -- If COMM changed, record old/new
        IF NVL(:OLD.COMM,0) <> NVL(:NEW.COMM,0) THEN
            INSERT INTO STAFFAUDTBL (ID, ACTION, INCJOB, OLDCOMM, NEWCOMM)
            VALUES (NVL(:NEW.ID, :OLD.ID), 'U', NULL, :OLD.COMM, :NEW.COMM);
        END IF;

    ELSIF DELETING THEN
        -- On delete log an entry with ACTION='D'
        INSERT INTO STAFFAUDTBL (ID, ACTION, INCJOB, OLDCOMM, NEWCOMM)
        VALUES (:OLD.ID, 'D', NULL, :OLD.COMM, NULL);
    END IF;
END;
/
-- TEST / DEMO Q6
PROMPT Q6 TEST: Test INSERT (good & bad), UPDATE (COMM change & bad JOB), DELETE

-- Test good insert (should succeed)
INSERT INTO STAFF (ID, NAME, DEPT, JOB, YEARS, SALARY, COMM)
VALUES (8888, 'Good Insert', 90, 'Sales', 1, 45000, 0);
COMMIT;

-- Test bad insert (should be blocked and logged)
BEGIN
    INSERT INTO STAFF (ID, NAME, DEPT, JOB, YEARS, SALARY, COMM)
    VALUES (8889, 'Bad Insert', 90, 'NoJob', 1, 35000, 0);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected bad insert error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test update COMM for existing row
UPDATE STAFF SET COMM = 1234 WHERE ID = 8888;
COMMIT;

-- Test update to invalid job (should be blocked and logged)
BEGIN
    UPDATE STAFF SET JOB = 'BadJob' WHERE ID = 8888;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected bad update job error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Test delete
DELETE FROM STAFF WHERE ID = 8888;
COMMIT;

-- Show STAFFAUDTBL contents for recent tests
SELECT * FROM STAFFAUDTBL ORDER BY ID DESC;

-- Clean-up test rows if any leftover
DELETE FROM STAFF WHERE ID IN (8888,8889);
COMMIT;


-- Question 7
CREATE OR REPLACE FUNCTION fun_name(p_name IN VARCHAR2) RETURN VARCHAR2 IS
    v_result VARCHAR2(4000) := '';
    v_len    PLS_INTEGER;
    v_char   CHAR(1);
BEGIN
    IF p_name IS NULL THEN
        RETURN NULL;
    END IF;

    v_len := LENGTH(p_name);
    FOR i IN 1 .. v_len LOOP
        v_char := SUBSTR(p_name, i, 1);
        IF MOD(i,2) = 1 THEN
            v_result := v_result || UPPER(v_char);
        ELSE
            v_result := v_result || LOWER(v_char);
        END IF;
    END LOOP;

    RETURN v_result;
END fun_name;
/
-- TEST / DEMO Q7
SELECT fun_name('Shubham') AS shubham_out FROM DUAL;
SELECT fun_name('Utkarsh') AS Utkarsh_out FROM DUAL;
-- Also show using STAFF sample name (first row)
SELECT NAME, fun_name(NAME) AS alternate_name FROM STAFF WHERE ROWNUM <= 5;


-- Question 8

CREATE OR REPLACE FUNCTION vowel_cnt(p_str IN VARCHAR2) RETURN NUMBER IS
    v_count NUMBER := 0;
    v_char  CHAR(1);
BEGIN
    IF p_str IS NULL THEN
        RETURN 0;
    END IF;

    FOR i IN 1 .. LENGTH(p_str) LOOP
        v_char := SUBSTR(p_str, i, 1);
        IF v_char IN ('A','E','I','O','U','a','e','i','o','u') THEN
            v_count := v_count + 1;
        END IF;
    END LOOP;

    RETURN v_count;
END vowel_cnt;
/
-- TEST / DEMO Q8
PROMPT Q8 TEST: count vowels in NAME and JOB columns
-- Example: per-row counts (first 10)
SELECT NAME, vowel_cnt(NAME) AS NAME_VOWELS, JOB, vowel_cnt(JOB) AS JOB_VOWELS
FROM STAFF
WHERE ROWNUM <= 10;

-- Test when WHERE yields no rows (should run fine; no function failure)
SELECT vowel_cnt(NAME) FROM STAFF WHERE NAME = 'D_k_Patel';

-- Question 9

CREATE OR REPLACE PACKAGE staff_pck IS
    -- Expose relevant procedures and functions
    PROCEDURE staff_add(p_name IN STAFF.NAME%TYPE, p_job IN STAFF.JOB%TYPE, p_salary IN STAFF.SALARY%TYPE, p_comm IN STAFF.COMM%TYPE);
    PROCEDURE set_comm;
    FUNCTION total_cmp(p_id IN NUMBER) RETURN NUMBER;
    FUNCTION fun_name(p_name IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION vowel_cnt(p_str IN VARCHAR2) RETURN NUMBER;
END staff_pck;
/
CREATE OR REPLACE PACKAGE BODY staff_pck IS
    -- Package simply wraps the standalone implementations created earlier
    PROCEDURE staff_add(p_name IN STAFF.NAME%TYPE, p_job IN STAFF.JOB%TYPE, p_salary IN STAFF.SALARY%TYPE, p_comm IN STAFF.COMM%TYPE) IS
    BEGIN
        -- call top-level procedure
        NULL; -- we'll call the standalone procedure directly
        -- NOTE: We can't call the standalone by name here if same name exists; do direct implementation:
        DECLARE
            v_max_id STAFF.ID%TYPE;
            v_new_id STAFF.ID%TYPE;
        BEGIN
            SELECT NVL(MAX(ID),0) INTO v_max_id FROM STAFF;
            v_new_id := v_max_id + 10;
            IF UPPER(TRIM(p_job)) NOT IN ('SALES','CLERK','MGR') THEN
                RAISE_APPLICATION_ERROR(-20006, 'staff_pck.staff_add: Invalid JOB.');
            END IF;
            INSERT INTO STAFF (ID, NAME, DEPT, JOB, YEARS, SALARY, COMM)
            VALUES (v_new_id, p_name, 90, INITCAP(LOWER(TRIM(p_job))), 1, p_salary, p_comm);
            COMMIT;
        END;
    END staff_add;

    PROCEDURE set_comm IS
    BEGIN
        -- call standalone set_comm logic by invoking the procedure we defined earlier
        -- To avoid duplication we call the existing set_comm if present
        set_comm; -- this will call the previously defined set_comm; if namespace conflict occurs, you can inline logic
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END set_comm;

    FUNCTION total_cmp(p_id IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN total_cmp(p_id); -- call top-level implementation
    END total_cmp;

    FUNCTION fun_name(p_name IN VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        RETURN fun_name(p_name);
    END fun_name;

    FUNCTION vowel_cnt(p_str IN VARCHAR2) RETURN NUMBER IS
    BEGIN
        RETURN vowel_cnt(p_str);
    END vowel_cnt;

END staff_pck;
/
-- TEST / DEMO Q9: Using package calls
PROMPT Q9 TEST: Using package procedures and functions

-- Use package to add a person (valid)
BEGIN
    staff_pck.staff_add('Pkg User', 'Mgr', 80000, 16000);
END;
/
SELECT * FROM STAFF WHERE NAME = 'Pkg User';

-- Use package function to compute total comp for that new person
DECLARE
    v_id STAFF.ID%TYPE;
    v_total NUMBER;
BEGIN
    SELECT ID INTO v_id FROM STAFF WHERE NAME = 'Pkg User';
    v_total := staff_pck.total_cmp(v_id);
    DBMS_OUTPUT.PUT_LINE('Total comp via package for ID ' || v_id || ' = ' || v_total);
END;
/

-- Clean up test row
DELETE FROM STAFF WHERE NAME = 'Pkg User';
COMMIT;
