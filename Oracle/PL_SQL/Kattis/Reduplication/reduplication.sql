DECLARE
   ans varchar2(100);
   ip varchar2(10);
   num integer;
   
BEGIN
    ip := :x;
    num := :y;
    
    for i in 1..num
    loop
        ans := ans || ip;
    end loop;
    dbms_output.put_line(ans);
END;
/
