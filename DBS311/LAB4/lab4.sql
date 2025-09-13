-- 1

SELECT DISTINCT C.customer_id, C.NAME
FROM customers C
JOIN orders O ON C.customer_id = O.customer_id
WHERE EXTRACT(YEAR FROM O.order_date) = 2017
MINUS
SELECT DISTINCT C.customer_id, C.NAME
FROM customers C
JOIN orders O ON C.customer_id = O.customer_id
WHERE EXTRACT(YEAR FROM O.order_date) = 2016;


--2 
SELECT DISTINCT C.customer_id, C.NAME
FROM customers C
JOIN orders O ON C.customer_id = O.customer_id
WHERE EXTRACT(YEAR FROM O.order_date) = 2016
INTERSECT
SELECT DISTINCT C.customer_id, C.NAME
FROM customers C
JOIN orders O ON C.customer_id = O.customer_id
WHERE EXTRACT(YEAR FROM O.order_date) = 2017;


--3
(
  SELECT DISTINCT C.CUSTOMER_ID, C.NAME
  FROM CUSTOMERS C
  JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
  WHERE EXTRACT(YEAR FROM O.ORDER_DATE) = 2016
  MINUS
  SELECT DISTINCT C.CUSTOMER_ID, C.NAME
  FROM CUSTOMERS C
  JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
  WHERE EXTRACT(YEAR FROM O.ORDER_DATE) = 2017
)
UNION
(
  SELECT DISTINCT C.CUSTOMER_ID, C.NAME
  FROM CUSTOMERS C
  JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
  WHERE EXTRACT(YEAR FROM O.ORDER_DATE) = 2017
  MINUS
  SELECT DISTINCT C.CUSTOMER_ID, C.NAME
  FROM CUSTOMERS C
  JOIN ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
  WHERE EXTRACT(YEAR FROM O.ORDER_DATE) = 2016
);


SELECT customer_id, name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE EXTRACT(YEAR FROM order_date) = 2016)
  AND customer_id NOT IN (SELECT customer_id FROM orders WHERE EXTRACT(YEAR FROM order_date) = 2017)
UNION
SELECT customer_id, name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE EXTRACT(YEAR FROM order_date) = 2017)
  AND customer_id NOT IN (SELECT customer_id FROM orders WHERE EXTRACT(YEAR FROM order_date) = 2016);
  
--4  

    SELECT c.customer_id,
           c.name
    FROM customers c
    JOIN orders o
      ON c.customer_id = o.customer_id
    WHERE EXTRACT(YEAR FROM o.order_date) IN (2016, 2017)
    GROUP BY c.customer_id, c.name
    HAVING COUNT(DISTINCT EXTRACT(YEAR FROM o.order_date)) = 1;


