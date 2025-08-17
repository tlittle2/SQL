DECLARE
   i integer := 1;
   a integer;
   
BEGIN
    a := :x;
    
    loop
    exit when i = a+1;
    dbms_output.put_line(i);
    i := i +1;
    end loop;
    
END;
/
