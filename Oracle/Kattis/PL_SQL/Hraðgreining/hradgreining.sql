DECLARE
   ip varchar2(1000);
BEGIN
    ip := :x;
    
    if regexp_instr(ip, 'COV') > 0
    then
        dbms_output.put_line('Veikur!');
    else
        dbms_output.put_line('Ekki veikur!');
    end if;
    
END;
/
