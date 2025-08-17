select name, line
, decode (type, 'PACKAGE', lower(name || '.pks'), 'PACKAGE BODY', lower(name || '.pkb'), lower(name) || '.sql') as file_name
, decode(line, 1, 'create or replace ' || text, text) AS TEXT
from user_source
order by name, decode(type, 'PACKAGE',1,2), line asc;


--Output to Unix File
select 'echo "' || text || '"' || ' >> ' || file_name from (
select name, line
, concat(translate(initcap(type), ' ', '_'),'s/') || decode(type, 'PACKAGE', lower(concat(name,'.pks')), 'PACKAGE BODY', lower(concat(name,'.pkb')), lower(concat(name, '.sql'))) as file_name
, decode(line, 1, 'create or replace ' || text, text) AS TEXT
from user_source
order by name, decode(type, 'PACKAGE',1,2), line asc
);
