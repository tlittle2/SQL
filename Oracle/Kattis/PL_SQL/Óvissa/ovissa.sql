DECLARE
   ans integer := 0;
   ip varchar2(100);   
BEGIN
    ip := :x;
    
    for i in 1..length(ip)
    loop
        if substr(ip, i, 1) = 'u'
        then
            ans := ans +1;
        end if;
    end loop;
    
    dbms_output.put_line(ans);
    
END;
/
