--=======================================primary key columns given input %rowtype=======================================
select lower(stmnt) from (
select 'procedure delete_' || columns.table_name || '_row(p_row IN ' || columns.table_name  || '%rowtype)'
|| 'is begin DELETE FROM ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_row.' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.position)
|| '; exception when others then raise; end delete_' || columns.table_name || ';'
as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
where constraints.table_name = 'ARCHIVE_RULES'
and constraints.constraint_type = 'P'
GROUP BY columns.TABLE_NAME
);


--=======================================primary key columns given input %rowtype=======================================

--=======================================indexed columns given input rowtype=======================================
select lower(stmnt) from (
select 'procedure delete_' || columns.table_name || '_row(p_row IN ' || columns.table_name||'%rowtype)'
|| 'is begin DELETE FROM ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_row.' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.COLUMN_POSITION)
|| '; exception when others then raise; end delete_' || columns.table_name || ';'
as stmnt
from user_ind_columns columns
where columns.table_name = 'ARCHIVE_RULES'
GROUP BY columns.TABLE_NAME
);

--=======================================indexed columns given input rowtype=======================================


--=======================================custom columns given rowtype=======================================

select lower(stmnt) from (
select 'procedure delete_' || columns.table_name || '_row(p_row IN ' || columns.TABLE_NAME || '%rowtype)'
|| 'is begin DELETE FROM ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_row.' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.column_Id)
|| '; exception when others then raise; end delete_' || columns.table_name || ';'
as stmnt
from user_tab_columns columns
where columns.table_name = 'ARCHIVE_RULES'
and columns.column_name in ('TABLE_OWNER', 'YEARS_TO_KEEP')
GROUP BY columns.TABLE_NAME
);

--=======================================custom columns given rowtype=======================================
