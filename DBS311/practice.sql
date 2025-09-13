set serveroutput on;
-- Write an Oracle PL/SQL function named find_max_value that takes two numbers (num1 and num2) as input parameters and returns the maximum value between them. Both parameters are of type NUMBER.

create or replace function find_max_value (num1 number, num2 number)
return NUMBER
is
max_value number;
begin
if num1 > num2 then 
max_value := num1 ;
else 
max_value := num2;

end if;

return max_value;
end;
/

begin
dbms_output.put_line(find_max_value(12,99));
end;
/

-- Write an Oracle PL/SQL function named calculate_square that takes a number as an input (number of type NUMBER) and returns its square as output (type NUMBER).

create or replace function calculate_square(num1 number)
return number

is 
square number;
begin
if num1 > 0 then
square := num1 * num1;
else 
dbms_output.put_line('Invalid Output');
end if;
end;
/

begin
dbms_output.put_line(calculate_square(12,99));
end;
/



