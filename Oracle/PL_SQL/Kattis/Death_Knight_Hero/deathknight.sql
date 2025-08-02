DECLARE
   word varchar2(100);
   ans integer := 0;
         
BEGIN
    word := :x;
    
    if regexp_instr(word, 'CD') > 0
    then
        ans := ans + 1;
    end if;
    
    dbms_output.put_line(ans);
    
END;
/
