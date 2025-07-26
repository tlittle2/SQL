--for primary key columns
select lower(stmnt) from (
select 'procedure get_' || columns.table_name || '_1' -- change number here if you want multiple "getter" procedures
|| '(' || LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.position)
|| ',p_' || columns.table_name || '_row IN OUT ' || columns.table_name || '%rowtype)'
|| 'is begin select * into  p_' || columns.table_name || '_row' || ' from ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.position)
|| '; exception when no_data_found then raise; when too_many_rows then raise; end get_' || columns.table_name || '_1;' -- change number here if you want multiple "getter" procedures
as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
where constraints.table_name = 'SALARY_DATA_STG'
and constraints.constraint_type = 'P'
GROUP BY columns.TABLE_NAME
);


--for custom columns
select lower(stmnt) from (
select 'procedure get_' || columns.table_name || '_1' -- change number here if you want multiple "getter" procedures
|| '(' || LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.column_id)
|| ',p_' || columns.table_name || '_row IN OUT ' || columns.table_name || '%rowtype)'
|| 'is begin select * into  p_' || columns.table_name || '_row' || ' from ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.column_id)
|| '; exception when no_data_found then raise; when too_many_rows then raise; end get_' || columns.table_name || '_1;' -- change number here if you want multiple "getter" procedures
as stmnt
from user_tab_columns columns
where columns.table_name = 'SALARY_DATA_STG'
and column_name in ('CASE_NUM', 'ID')
GROUP BY columns.TABLE_NAME
);
