--every column accounted for in parameter
select lower(stmnt) from (
select 'procedure insert_' || table_name || '(' || LISTAGG('p_' || COLUMN_NAME || ' ' || table_name || '.' || column_name || '%type DEFAULT NULL', ' , ') WITHIN GROUP (ORDER BY COLUMN_ID) || ')'
|| 'is begin INSERT INTO '
|| table_name
|| ' VALUES '
|| '('
|| LISTAGG('p_' || COLUMN_NAME, ' , ')  WITHIN GROUP (ORDER BY COLUMN_ID)
|| '); exception when others then raise; end insert_' || table_name || ';' as stmnt
from user_tab_columns
where table_name = 'ASTROLOGY' --modify procedure accordingly for your particular where clause
GROUP BY TABLE_NAME
);

