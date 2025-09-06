declare
    a integer := 5;

begin
    for i in 1..12
    loop
        dbms_output.put_line(a * i);
    end loop;
end;
/
