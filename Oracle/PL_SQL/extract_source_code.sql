set serveroutput on;
declare
cursor code_source
is
select name, line, text as text
from user_source where name = 'GENERATE_GUID'
order by decode(type, 'PACKAGE',1,2), line asc;

begin
for rec in code_source
loop
    if rec.line = 1
    then
        dbms_output.put_line('create or replace ' || rec.text);
    else
        dbms_output.put_line(rec.text);
    end if;
end loop;
end;
/
