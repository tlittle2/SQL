select 'procedure update_' || lower(table_name) || '(' || LISTAGG('p_' || COLUMN_NAME || ' ' || column_name || '%type', ' , ') WITHIN GROUP (ORDER BY COLUMN_ID) || ')'
|| 'is begin UPDATE ' || lower(table_name) || ' set ' || LISTAGG(COLUMN_NAME || ' = nvl(' ||'p_' || COLUMN_NAME || ',' || column_name || ')', ' , ') WITHIN GROUP (ORDER BY COLUMN_ID)
|| '; end;'
from all_tab_columns
where table_name = 'SALARY_DATA_STG'
GROUP BY TABLE_NAME;
