DECLARE
   a varchar2(20);
   
BEGIN
    a := :x;
    dbms_output.put_line(substr(a,1,1));
END;
/
