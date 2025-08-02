set serveroutput on
DECLARE
   a integer;
   b integer;
   c integer;

BEGIN
    a := :x;
    b := :y;
    c := :z;
    
    dbms_output.put_line(c - (a + b));

END;
/
