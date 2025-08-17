DECLARE
   mx integer;
   str varchar2(100);
   
BEGIN
    str:= :x;
    mx := :y;
    
    for i in 1..mx
    loop
        dbms_output.put_line('Hipp hipp hurra,' || str || '!');
    end loop;
    
END;
/
