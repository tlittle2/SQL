select 'drop ' || substr(text
     , 1
     , decode(instr(text, '('), 0, length(text), instr(text, '(')-1)
) || ';' as text
from user_source a
where type in ('PACKAGE', 'PACKAGE BODY', 'FUNCTION')
and line = 1;
