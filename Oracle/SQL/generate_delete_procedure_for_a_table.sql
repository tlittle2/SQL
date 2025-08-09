--=======================================delete by rowid=======================================
select lower(stmnt) from (
select 'procedure delete_' || columns.table_name || '_rowid(p_rowid IN rowid)'
|| 'is begin DELETE FROM ' || columns.table_name || ' WHERE rowid = p_rowid'
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

--=======================================delete by rowid=======================================


--=======================================primary key columns=======================================
select lower(stmnt) from (
select 'procedure delete_' || columns.table_name || '_2(' || LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ' , ') WITHIN GROUP (ORDER BY columns.position) || ')'
|| 'is begin DELETE FROM ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.position)
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

select case
when (s_order, nxt) in ((2,3)) then substr(stmnt, 1, length(stmnt) -1) --remove last comma in parameters
when (s_order, nxt) in ((4,5)) then substr(stmnt, 1, length(stmnt) -4) --remove last and in the where clause
else stmnt end as stmnt from (
select s_order, lead(s_order, 1) over (order by table_name,s_order asc) as nxt, lower(stmnt) as stmnt from (
select 1 as s_order, table_name as table_name, null as column_name, 0 as column_id, 'procedure delete_' || tab.table_name|| '_2('  as stmnt
from user_tables tab

union all

select 2 as s_order, cols.table_name as table_name, cols.column_name as column_name, column_id as column_id, 'p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type,' as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
inner join user_tab_columns cols
on columns.table_name = cols.table_name
and columns.column_name = cols.column_name
where constraints.constraint_type = 'P'


union all

select 3 as s_order, table_name as table_name, null as column_name, 32767 as column_id, ') is begin delete from ' || table_name || ' where '
from user_tables

union all

select 4 s_order, cols.table_name as table_name, cols.column_name as column_name, column_id as column_id, '' || columns.COLUMN_NAME || ' = ' || 'p_' || columns.column_name || ' and ' as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
inner join user_tab_columns cols
on columns.table_name = cols.table_name
and columns.column_name = cols.column_name
where constraints.constraint_type = 'P'

union all

select 5 as s_order, table_name as table_name, null as column_name, 32767 * 2 as column_id, '; exception when others then raise; end delete_' || tab.table_name|| '_2;' as stmnt
from user_tables tab
)order by table_name, s_order, column_id
);


--=======================================primary key columns=======================================


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



--=======================================indexed columns=======================================

select lower(stmnt) from (
select 'procedure delete_' || columns.table_name || '_3(' || LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ' , ') WITHIN GROUP (ORDER BY columns.COLUMN_POSITION) || ')'
|| 'is begin DELETE FROM ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.COLUMN_POSITION)
|| '; exception when others then raise; end delete_' || columns.table_name || ';'
as stmnt
from user_ind_columns columns
where columns.table_name = 'ARCHIVE_RULES'
GROUP BY columns.TABLE_NAME
);

--=======================================indexed columns=======================================



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


--=======================================custom columns=======================================

--
select lower(stmnt) from (
select 'procedure delete_' || columns.table_name || '(' || LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ' , ') WITHIN GROUP (ORDER BY columns.column_Id) || ')'
|| 'is begin DELETE FROM ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.column_Id)
|| '; exception when others then raise; end delete_' || columns.table_name || ';'
as stmnt
from user_tab_columns columns
where columns.table_name = 'ARCHIVE_RULES'
and columns.column_name in ('TABLE_OWNER', 'YEARS_TO_KEEP')
GROUP BY columns.TABLE_NAME
);

--=======================================custom columns=======================================


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
