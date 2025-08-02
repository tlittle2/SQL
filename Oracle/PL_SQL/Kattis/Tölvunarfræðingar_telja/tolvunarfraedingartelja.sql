DECLARE
   a integer;
BEGIN
    a := :x;    
    dbms_output.put_line(a - 1);

END;
/
