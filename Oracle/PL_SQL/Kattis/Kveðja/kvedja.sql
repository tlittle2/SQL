DECLARE
   a varchar2(100);
   
BEGIN
    dbms_output.put_line('Kvedja,');
    a := :x;
    dbms_output.put_line(a);

END;
/
