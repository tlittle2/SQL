select lower(stmnt) from (
select 'procedure insert_' || lower(table_name) || '(' || LISTAGG('p_' || COLUMN_NAME || ' ' || column_name || '%type DEFAULT NULL', ' , ') WITHIN GROUP (ORDER BY COLUMN_ID) || ')'
|| 'is begin INSERT INTO '
|| lower(table_name) || ' VALUES (' || LISTAGG('p_' || COLUMN_NAME, ' , ')  WITHIN GROUP (ORDER BY COLUMN_ID)
|| '); end;' as stmnt
from user_tab_columns
where table_name = 'ASTROLOGY'
GROUP BY TABLE_NAME
);
