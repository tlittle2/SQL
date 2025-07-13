select lower(stmnt) from (
select 'procedure update_' || tab.table_name || '(' || LISTAGG('p_' || tab.COLUMN_NAME || ' ' || tab.table_name || '.' || tab.column_name || '%type DEFAULT NULL', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID) || ')'
|| 'is begin UPDATE '
|| tab.table_name || ' set ' || LISTAGG(tab.COLUMN_NAME || ' = nvl(' ||'p_' || tab.COLUMN_NAME || ',' || tab.column_name || ')', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID)
|| '; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);
