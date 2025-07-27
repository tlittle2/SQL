--let modern IDEs take care of creating getters and setters for you

--camel case
with ds as(
select column_name, data_type, data_length, data_precision,replace(initcap(replace(column_name, '_', ' ')), ' ') as converted
from all_tab_columns
where table_name = 'ERROR_LOG'
order by column_id asc
)

select 'private ' || case 
    when upper(data_type) = 'CHAR' then 'char'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) = 0 then 'int'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) > 0 then 'double'
    when upper(data_type) = 'INTEGER' then 'int'
    when upper(data_type) = 'DATE' then 'java.util.Date'
    when upper(substr(data_type, 1,9)) = 'TIMESTAMP' then 'java.util.Date'
    when upper(data_type) = 'FLOAT' then 'float'
    when upper(data_type) = 'VARCHAR2' then 'String'
    when upper(data_type) = 'NVARCHAR2' then 'String'
    end || ' ' || replace(converted, substr(converted,1,1), lower(substr(converted,1,1))) || ';' as java_type 
 from ds;




--original
select column_name, data_type, data_length, data_precision
, 'private ' || case 
    when upper(data_type) = 'CHAR' then 'char'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) = 0 then 'int'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) > 0 then 'double'
    when upper(data_type) = 'INTEGER' then 'int'
    when upper(data_type) = 'DATE' then 'java.util.Date'
    when upper(substr(data_type, 1,9)) = 'TIMESTAMP' then 'java.util.Date'
    when upper(data_type) = 'FLOAT' then 'float'
    when upper(data_type) = 'VARCHAR2' then 'String'
    when upper(data_type) = 'NVARCHAR2' then 'String'
    end || ' ' || replace(initcap(replace(column_name, '_', ' ')), ' ') || ';' as java_type 
 from all_tab_columns
where table_name = 'SALARY_DATA_STG'
order by column_id asc;
