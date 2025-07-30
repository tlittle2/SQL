--let modern IDEs take care of creating getters and setters for you, but just in case you want it

--camel case
with java_types as(
select column_name, data_type, data_length, data_precision,replace(initcap(replace(column_name, '_', ' ')), ' ') as converted
, case 
    when upper(data_type) = 'CHAR' then 'char'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) = 0 then
        case when data_length <= 10 then 'int' else 'double' end
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) > 0 then 'double'
    when upper(data_type) = 'INTEGER' then 'int'
    when upper(data_type) = 'DATE' then 'java.util.Date'
    when upper(substr(data_type, 1,9)) = 'TIMESTAMP' then 'java.util.Date'
    when upper(data_type) = 'FLOAT' then 'float'
    when upper(data_type) = 'VARCHAR2' then 'String'
    when upper(data_type) = 'NVARCHAR2' then 'String'
    end as java_type
from all_tab_columns
where table_name = 'SALARY_DATA_STG'
--and column_name in ('CASE_NUM' , 'FIELD' , 'YEAR' , 'SALARY')
order by column_id asc
)

, ds as(
    select replace(converted, substr(converted,1,1), lower(substr(converted,1,1))) as java_variable, java_types.*
    from java_types
)

select 'private ' || java_type || ' ' || java_variable || ';' as java_var
, 'public ' || java_type || ' get_' || initcap(java_variable) || '(){return ' || java_variable || ';}' as getter
, 'public ' || java_type || ' set_' || initcap(java_variable) || '(' || java_type || ' ' || java_variable || ')' || '{this.' || java_variable || '= ' || java_variable || ';' || '}' as setter
, 'public String get_' || java_variable || 'Column() { return "' || upper(column_name) || '";' || '}' as column_getter --good for ResultSet object
 from ds;



--========================================================================================================================================================================================


--camel case
with ds as(
select column_name, data_type, data_length, data_precision,replace(initcap(replace(column_name, '_', ' ')), ' ') as converted
from all_tab_columns
where table_name = 'SALARY_DATA_STG'
--and column_name in ('CASE_NUM' , 'FIELD' , 'YEAR' , 'SALARY')
order by column_id asc
)

select 'private ' || case 
    when upper(data_type) = 'CHAR' then 'char'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) = 0 then
        case when data_length <= 10 then 'int' else 'double' end
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) > 0 then 'double'
    when upper(data_type) = 'INTEGER' then 'int'
    when upper(data_type) = 'DATE' then 'java.util.Date'
    when upper(substr(data_type, 1,9)) = 'TIMESTAMP' then 'java.util.Date'
    when upper(data_type) = 'FLOAT' then 'float'
    when upper(data_type) = 'VARCHAR2' then 'String'
    when upper(data_type) = 'NVARCHAR2' then 'String'
    end || ' ' || replace(converted, substr(converted,1,1), lower(substr(converted,1,1))) || ';' as java_type 
 from ds;


--camel case for wrapper classes
with ds as(
select column_name, data_type, data_length, data_precision,replace(initcap(replace(column_name, '_', ' ')), ' ') as converted
from all_tab_columns
where table_name = 'SALARY_DATA_STG'
--and column_name in ('CASE_NUM' , 'FIELD' , 'YEAR' , 'SALARY')
order by column_id asc
)

select 'private ' || case 
    when upper(data_type) = 'CHAR' then 'Character'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) = 0 then
        case when data_length <= 10 then 'Integer' else 'Double' end
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) > 0 then 'Double'
    when upper(data_type) = 'INTEGER' then 'Integer'
    when upper(data_type) = 'DATE' then 'java.sql.Date'
    when upper(substr(data_type, 1,9)) = 'TIMESTAMP' then 'java.sql.Date'
    when upper(data_type) = 'FLOAT' then 'Float'
    when upper(data_type) = 'VARCHAR2' then 'String'
    when upper(data_type) = 'NVARCHAR2' then 'String'
    end || ' ' || replace(converted, substr(converted,1,1), lower(substr(converted,1,1))) || ';' as java_type 
 from ds;



--Create Java Record out of datatypes
with ds as(
select column_name, data_type, data_length, data_precision,replace(initcap(replace(column_name, '_', ' ')), ' ') as converted
from all_tab_columns
where table_name = 'SALARY_DATA_STG'
--and column_name in ('CASE_NUM' , 'FIELD' , 'YEAR' , 'SALARY')
order by column_id asc
)

select case 
    when upper(data_type) = 'CHAR' then 'char'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) = 0 then
        case when data_length <= 10 then 'int' else 'double' end
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) > 0 then 'double'
    when upper(data_type) = 'INTEGER' then 'int'
    when upper(data_type) = 'DATE' then 'java.util.Date'
    when upper(substr(data_type, 1,9)) = 'TIMESTAMP' then 'java.util.Date'
    when upper(data_type) = 'FLOAT' then 'float'
    when upper(data_type) = 'VARCHAR2' then 'String'
    when upper(data_type) = 'NVARCHAR2' then 'String'
    end || ' ' || replace(converted, substr(converted,1,1), lower(substr(converted,1,1))) || ',' as java_type 
 from ds;

--original
select column_name, data_type, data_length, data_precision
, 'private ' || case 
    when upper(data_type) = 'CHAR' then 'char'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) = 0 then
        case when data_length <= 10 then 'int' else 'double' end
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
--and column_name in ('CASE_NUM' , 'FIELD' , 'YEAR' , 'SALARY')
order by column_id asc;
