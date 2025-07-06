DECLARE
    ip varchar2(100) := 'PieHard 3.14159265358979323846';

    ip_title VARCHAR2(100) := substr(ip, 1, instr(ip, ' ') - 1);
    ip_cost FLOAT(10) := cast(trim(substr(ip, instr(ip, ' ') + 1)) as float);
    title_length INTEGER := length(ip_title);    

BEGIN
    IF ip_cost < title_length
    THEN
        dbms_output.put_line(ip_cost);
    ELSE
        dbms_output.put_line(title_length);
    END IF;
END;
