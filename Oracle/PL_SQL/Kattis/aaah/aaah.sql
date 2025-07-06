DECLARE
    ip1 varchar2(999) := 'ahhhhhh';
    ip2 varchar2(999) := 'aahh';
    
BEGIN
    if length(ip1) >= length(ip2)
    then
        dbms_output.put_line('go');
    else
        dbms_output.put_line('no');
    end if;
END;
