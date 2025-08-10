--for a %rowtype variable
select lower(stmnt) from (
select 'procedure insert_' || table_name || '_row(p_row IN ' || tab.table_name  || '%rowtype)'
|| 'is begin INSERT INTO '
|| table_name
|| ' VALUES '
|| '('
|| LISTAGG('p_row.' || COLUMN_NAME, ' , ')  WITHIN GROUP (ORDER BY COLUMN_ID)
|| '); exception when others then raise; end insert_' || table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);


--===========================if the table is too wide (list_agg()) does have its limitations===========================

--select lower(stmnt) from (
select 'procedure insert_' || table_name || '_row(p_row IN ' || tab.table_name  || '%rowtype) is begin INSERT INTO ' || tab.table_name || ' VALUES (' as stmnt
from all_tables tab
where tab.table_name in ('SALARY_DATA_STG')

union all

select 'p_row.' || tab.column_name || ','
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG')

union all

select '); exception when others then raise; end insert_' || table_name || ';' 
from all_tables tab
where tab.table_name in ('SALARY_DATA_STG')
);
--===========================if the table is too wide (list_agg()) does have its limitations===========================

