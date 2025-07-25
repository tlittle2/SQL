select lower(stmnt) from (
select 'procedure get_' || columns.table_name || '_1(' || LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.position)
|| ',p_' || columns.table_name || '_row IN OUT ' || columns.table_name || '%rowtype)'
|| 'is begin select * into  p_' || columns.table_name || '_row' || ' from ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.position)
|| '; end get_' || columns.table_name || '_1;'
as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
where constraints.table_name = 'ARCHIVE_RULES'
and constraints.constraint_type = 'P'
GROUP BY columns.TABLE_NAME
);
