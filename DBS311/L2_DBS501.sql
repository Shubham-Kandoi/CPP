-- NAME: SHUBHAM KANDOI
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE factorial(n IN NUMBER, result OUT NUMBER) IS
BEGIN
    IF n = 0 THEN
        result := 1;  -- Base case: 0! = 1
    ELSE
        DECLARE
            temp_result NUMBER;
        BEGIN
            factorial(n - 1, temp_result);  -- Recursive call
            result := n * temp_result;       -- Calculate factorial
        END;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        result := NULL;
END;
/

CREATE OR REPLACE PROCEDURE fibonacci (
    n IN NUMBER,
    fib_sum OUT NUMBER
) IS
    f0 NUMBER := 0;
    f1 NUMBER := 1;
    temp NUMBER;
    i NUMBER;
BEGIN
    IF n < 0 THEN
        fib_sum := 0;  -- Negative input case
        RETURN;
    ELSIF n = 0 THEN
        fib_sum := 0;  -- Sum for 0
        RETURN;
    ELSIF n = 1 THEN
        fib_sum := 1;  -- Sum for 1
        RETURN;
    END IF;

    fib_sum := f0 + f1;  -- Start sum with first two Fibonacci numbers

    FOR i IN 2 .. n LOOP
        temp := f0 + f1;
        fib_sum := fib_sum + temp;  -- Accumulate sum
        f0 := f1;
        f1 := temp;
    END LOOP;
END fibonacci;
/

CREATE OR REPLACE PROCEDURE update_price_by_cat (
    p_category_id IN products.category_id%TYPE,
    p_amount IN products.list_price%TYPE
) IS
    rows_updated NUMBER;
BEGIN
    UPDATE products
    SET list_price = list_price + p_amount
    WHERE category_id = p_category_id
      AND list_price > 0;

    rows_updated := SQL%ROWCOUNT;  -- Count updated rows

    DBMS_OUTPUT.PUT_LINE('Rows updated: ' || rows_updated);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END update_price_by_cat;
/

CREATE OR REPLACE PROCEDURE update_price_under_avg IS
    avg_price products.list_price%TYPE;
    rows_updated NUMBER;
BEGIN
    SELECT AVG(list_price) INTO avg_price FROM products;  -- Get average price

    IF avg_price <= 1000 THEN
        UPDATE products
        SET list_price = list_price * 1.02
        WHERE list_price < avg_price;  -- Increase by 2%
    ELSE
        UPDATE products
        SET list_price = list_price * 1.01
        WHERE list_price < avg_price;  -- Increase by 1%
    END IF;

    rows_updated := SQL%ROWCOUNT;  -- Rows updated count

    DBMS_OUTPUT.PUT_LINE('Rows updated: ' || rows_updated);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END update_price_under_avg;
/

CREATE OR REPLACE PROCEDURE product_price_report IS
    avg_price products.list_price%TYPE;
    min_price products.list_price%TYPE;
    max_price products.list_price%TYPE;

    cheap_count NUMBER := 0;
    fair_count NUMBER := 0;
    exp_count NUMBER := 0;

    cheap_threshold NUMBER;
    expensive_threshold NUMBER;

BEGIN
    SELECT AVG(list_price), MIN(list_price), MAX(list_price)
    INTO avg_price, min_price, max_price
    FROM products;  -- Get price stats

    cheap_threshold := (avg_price - min_price) / 2;
    expensive_threshold := (max_price - avg_price) / 2;

    SELECT COUNT(*)
    INTO cheap_count
    FROM products
    WHERE list_price < cheap_threshold;  -- Count cheap products

    SELECT COUNT(*)
    INTO exp_count
    FROM products
    WHERE list_price > expensive_threshold;  -- Count expensive products

    SELECT COUNT(*)
    INTO fair_count
    FROM products
    WHERE list_price >= cheap_threshold
      AND list_price <= expensive_threshold;  -- Count fair priced products

    DBMS_OUTPUT.PUT_LINE('Cheap: ' || cheap_count);
    DBMS_OUTPUT.PUT_LINE('Fair: ' || fair_count);
    DBMS_OUTPUT.PUT_LINE('Expensive: ' || exp_count);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END product_price_report;
/

--1 
DECLARE
    result NUMBER;
BEGIN
    factorial(5, result);
    DBMS_OUTPUT.PUT_LINE('Factorial(5): ' || result); 

    factorial(0, result);
    DBMS_OUTPUT.PUT_LINE('Factorial(0): ' || result); 
END;
/

-- 2
DECLARE
    fib_sum NUMBER;
BEGIN
    fibonacci(5, fib_sum);
    DBMS_OUTPUT.PUT_LINE('Fibonacci sum up to 5: ' || fib_sum);  

    fibonacci(0, fib_sum);
    DBMS_OUTPUT.PUT_LINE('Fibonacci sum up to 0: ' || fib_sum);
END;
/

-- 3
BEGIN
    update_price_by_cat(1, 5);  

    update_price_by_cat(2, 10);
END;
/

--4 
BEGIN
    update_price_under_avg; 

    update_price_under_avg;  
END;
/

--5
BEGIN
    product_price_report; 

    product_price_report; 
END;
/

