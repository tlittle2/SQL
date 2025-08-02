DECLARE
   a integer;
   
BEGIN
    a := :x;
    
    if mod(a,10) = 0
    then
        dbms_output.put_line('Jebb');
    else
        dbms_output.put_line('Neibb');
    end if;
    
END;
/
