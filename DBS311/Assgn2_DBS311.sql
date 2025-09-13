-- Assignment 2: Stored Procedures 
-- 1 find_customer (customer_id IN NUMBER, found OUT NUMBER); 
CREATE OR REPLACE PROCEDURE find_customer(
    customer_id IN NUMBER,
    found OUT NUMBER
) AS
    v_count NUMBER;
BEGIN
    -- Count how many times CUSTOMER_ID appears
    SELECT COUNT(*) INTO v_count 
    FROM CUSTOMERS 
    WHERE CUSTOMER_ID = customer_id;

    -- Set found value based on count
    IF v_count = 0 THEN
        found := 0;  -- Customer not found
    ELSIF v_count = 1 THEN
        found := 1;  -- Customer found
    ELSE
        DBMS_OUTPUT.PUT_LINE('Customer exists but has multiple records.');
        found := 1; -- Still mark as found since customer exists
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        found := 0; -- No record found
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Customer exists but has multiple records.');
        found := 1; -- Set found as 1 since customer exists
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
        found := 0;
END;
/

SET SERVEROUTPUT ON;
DECLARE
    v_found NUMBER;
BEGIN
    find_customer(1, v_found);
    end;
/

