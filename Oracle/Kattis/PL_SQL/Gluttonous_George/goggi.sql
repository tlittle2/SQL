DECLARE
   subtype varchar_st is varchar2(100);

   str varchar_st := :x; --26 ? 26
   replce varchar_st := replace(str, '?');   
   delim integer := instr(replce, ' ' );
   
   a integer := to_number(substr(replce, 1, delim));
   b integer := to_number(substr(replce, delim, length(replce)));
   
   ans varchar_st;
   
BEGIN
    dbms_output.put_line(a);
    dbms_output.put_line(b);
    
    case
        when a > b then ans := '>';
        when a < b then ans :=  '<';
        else ans := 'Goggi svangur!';
    end case;
    
    dbms_output.put_line(ans);
    
END;
/
