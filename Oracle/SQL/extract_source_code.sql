select name, line, decode(line, 1 , 'create or replace ' || text, text) as text
from user_source where name in('INFA_GLOBAL_TBL_PKG', 'MATH_PKG', 'GENERATE_GUID')
order by name, decode(type, 'PACKAGE',1,2), line asc;
