--camel case
with ds as(
select column_name, data_type, data_length, data_precision,replace(initcap(replace(column_name, '_', ' ')), ' ') as converted
from all_tab_columns
where table_name = 'SALARY_DATA_STG'
and column_name in ('CASE_NUM' , 'FIELD' , 'YEAR' , 'SALARY')
order by column_id asc
)

select 'case class myClass (' as case_class
from dual

union all

select replace(converted, substr(converted,1,1), lower(substr(converted,1,1))) || ': '
|| case 
    when upper(data_type) = 'CHAR' then 'Char'
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) = 0 then
        case when data_length <= 10 then 'Int' else 'Double' end
    when upper(data_type) = 'NUMBER' and nvl(data_precision,0) > 0 then 'double'
    when upper(data_type) = 'INTEGER' then 'Int'
    when upper(data_type) = 'DATE' then 'java.util.Date'
    when upper(substr(data_type, 1,9)) = 'TIMESTAMP' then 'java.util.Date'
    when upper(data_type) = 'FLOAT' then 'Float'
    when upper(data_type) = 'VARCHAR2' then 'String'
    when upper(data_type) = 'NVARCHAR2' then 'String'
    end || ',' as java_type 
 from ds

union all

select ')' from dual;
