-- NAME: SHUBHAM DHARMENDRABHAI KANDOI
-- STUDENT ID: 144838232

CREATE OR REPLACE FUNCTION pig_latin(name_in IN VARCHAR2)
RETURN VARCHAR2
IS
    first_char CHAR(1); -- Stores First Letter of the name
    result VARCHAR2(50);
BEGIN
    first_char := LOWER(SUBSTR(TRIM(name_in), 1, 1));
    
    IF first_char IN ('a', 'e', 'i', 'o', 'u') THEN -- checking that if the first letter is vowel (a,e,i,o,u) 
        result := TRIM(name_in) || 'ay'; -- if it is vowel add 'ay' at the end of the name
    ELSE
        result := SUBSTR(TRIM(name_in), 2) || first_char || 'ay';
    END IF;
    
    RETURN result;
END;
/


CREATE OR REPLACE FUNCTION experience(years_in IN NUMBER)
RETURN VARCHAR2
IS
    level VARCHAR2(20);
BEGIN
    IF years_in BETWEEN 0 AND 4 THEN --     -- Check if years are in range and assign the level accordingly
        level := 'Junior';
    ELSIF years_in BETWEEN 5 AND 9 THEN
        level := 'Intermediate';
    ELSE
        level := 'Experienced';
    END IF;

    RETURN level;
    
END;
/


-- Testing

-- Function: 1. pig_latin 

SELECT pig_latin('Harrison') AS result FROM dual;

SELECT pig_latin('Smith') AS result FROM dual;

SELECT pig_latin('Anderson') AS result FROM dual;

SELECT pig_latin('Urly') AS result FROM dual;

SELECT pig_latin('Shubham') AS result FROM dual;

SELECT pig_latin('Aadi') AS result FROM dual;

SELECT pig_latin('') AS result FROM dual;

SELECT pig_latin('A') AS result FROM dual;

SELECT pig_latin('  SHUBHAM KANDOI  ') AS result FROM dual;




-- 2. 

SELECT experience(2) FROM dual;       
SELECT experience(9) FROM dual;       
SELECT experience(22) FROM dual;
SELECT experience(0) FROM dual;
SELECT experience(1.56) FROM dual;









