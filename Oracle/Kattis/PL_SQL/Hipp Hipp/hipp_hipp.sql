DECLARE
   i integer := 0;
   mx integer := 20;

BEGIN
    loop
        exit when i = mx;
        dbms_output.put_line('Hipp hipp hurra!');
        i :=  i+1;
    end loop;
END;
/
