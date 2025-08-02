DECLARE
   a integer;
   b integer;

BEGIN
    a := :x;
    b := :y;
    
    dbms_output.put_line(mod(a,b));

END;
/
