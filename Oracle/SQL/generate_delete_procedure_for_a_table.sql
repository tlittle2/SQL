select lower(stmnt) from (
select 'procedure delete_' || columns.table_name || '(' || LISTAGG('p_' || columns.COLUMN_NAME || ' ' || columns.table_name || '.' || columns.column_name || '%type', ' , ') WITHIN GROUP (ORDER BY columns.position) || ')'
|| 'is begin DELETE FROM ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.position)
|| '; end delete_' || columns.table_name || ';'
as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
where constraints.table_name = 'ARCHIVE_RULES'
and constraints.constraint_type = 'P'
GROUP BY columns.TABLE_NAME
);
