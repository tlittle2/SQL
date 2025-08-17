DECLARE
    sep CHAR(1) := '?';
    ip VARCHAR2(23) := '26 '|| sep || ' 26';
    a NUMBER := substr(ip, 1, instr(ip, sep)-2);
    b NUMBER := substr(ip, instr(ip, sep)+2, length(ip));
BEGIN
    dbms_output.put_line(a || ' ' || b);
    if a < b
    then
        dbms_output.put_line('<');
    elsif a > b
    then
        dbms_output.put_line('>');
    else
        dbms_output.put_line('Goggi svangur!');
    end if;

END;
