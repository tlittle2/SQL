DECLARE
   a integer;
   b integer;
   ans varchar2(15);

BEGIN
    a:= :x;
    b:= :y;
    
    case
        when a = b then ans:= 'WORLD WAR 3!';
        when a > b then ans := 'MAGA!';
        else ans := 'FAKE NEWS!';
    end case;
    
    dbms_output.put_line(ans);
END;
/
