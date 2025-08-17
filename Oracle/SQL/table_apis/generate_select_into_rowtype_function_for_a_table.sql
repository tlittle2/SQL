--for primary key columns
select lower(stmnt) from (
select 'function get_' || columns.table_name || '_1' -- change number here if you want multiple "getter" procedures
|| '('
|| LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.position)
|| ')'
|| ' return ' || columns.table_name || '%rowtype'
|| ' is ' || 'l_returnvalue ' || columns.table_name || '%rowtype;'
|| ' begin select * into l_returnvalue from ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.position) || ';'
|| ' return l_returnvalue;'
|| ' exception when no_data_found then raise; when too_many_rows then raise; when others then raise; end get_' || columns.table_name || '_1;' -- change number here if you want multiple "getter" procedures
as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
where constraints.table_name = 'SALARY_DATA'
and constraints.constraint_type = 'P'
GROUP BY columns.TABLE_NAME
);



--by rowid
select lower(stmnt) from (
select 'function get_' || columns.table_name || '_rowid' -- change number here if you want multiple "getter" procedures
|| '('
|| 'p_rowid IN rowid'
|| ')'
|| ' return ' || columns.table_name || '%rowtype'
|| ' is ' || 'l_returnvalue ' || columns.table_name || '%rowtype;'
|| 'begin select * into l_returnvalue from ' || columns.table_name
|| ' WHERE rowid = p_rowid;'
|| ' return l_returnvalue;'
|| ' exception when no_data_found then raise; when too_many_rows then raise; when others then raise; end get_' || columns.table_name || '_1;' -- change number here if you want multiple "getter" procedures
as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
where constraints.table_name = 'SALARY_DATA'
and constraints.constraint_type = 'P'
GROUP BY columns.TABLE_NAME
);



--by rowid AND primary key
select lower(stmnt) from (
select 'function get_' || columns.table_name || '_' || constraints.constraint_name || '_rowid' -- '_rowid2' change number here if you want multiple "getter" procedures
|| '('
|| 'p_rowid IN rowid, '
|| LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.position)
|| ')'
|| ' return ' || columns.table_name || '%rowtype'
|| ' is ' || 'l_returnvalue ' || columns.table_name || '%rowtype;'
|| 'begin select * into  l_returnvalue  from ' || columns.table_name
|| ' WHERE '
|| LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.position)
|| ' and  rowid = p_rowid;'
|| ' return l_returnvalue;'
|| ' exception when no_data_found then raise; when too_many_rows then raise; when others then raise; end get_' || columns.table_name || '_' || constraints.constraint_name || '_rowid;'  -- change number here if you want multiple "getter" procedures
as stmnt
from user_constraints constraints
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
where constraints.table_name = 'SALARY_DATA'
and constraints.constraint_type = 'P'
GROUP BY columns.TABLE_NAME,constraints.constraint_name
);




--for indexed columns
select lower(stmnt) from (
select 'function get_' || columns.table_name || '_' || columns.index_name --'_3' change number here if you want multiple "getter" procedures
|| '('
|| 'p_rowid IN rowid,'
|| LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.COLUMN_POSITION)
|| ')'
|| ' return ' || columns.table_name || '%rowtype'
|| ' is ' || 'l_returnvalue ' || columns.table_name || '%rowtype;'
|| 'begin select * into l_returnvalue from ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.COLUMN_POSITION)
|| ' and rowid = p_rowid;'
|| 'return l_returnvalue;'
|| 'exception when no_data_found then raise; when too_many_rows then raise; when others then raise; end get_'  || columns.table_name || '_' || columns.index_name ||';'--'_2;'  change number here if you want multiple "getter" procedures
as stmnt
from user_ind_columns columns
where columns.table_name in('INFA_GLOBAL', 'SALARY_DATA')
GROUP BY columns.TABLE_NAME , columns.index_name
);

--indexed columns AND rowid
select lower(stmnt) from (
select 'function get_' || columns.table_name || '_rowid3' -- change number here if you want multiple "getter" procedures
|| '('
|| 'p_rowid IN rowid,'
|| LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.COLUMN_POSITION)
|| ')'
|| ' return ' || columns.table_name || '%rowtype'
|| ' is ' || 'l_returnvalue ' || columns.table_name || '%rowtype;'
|| 'begin select * into  l_returnvalue from ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.COLUMN_POSITION)
|| ' and rowid = p_rowid;'
|| 'return l_returnvalue;'
|| 'exception when no_data_found then raise; when too_many_rows then raise; when others then raise; end get_' || columns.table_name || '_rowid3;' -- change number here if you want multiple "getter" procedures
as stmnt
from user_ind_columns columns
where columns.table_name in('SALARY_DATA')
GROUP BY columns.TABLE_NAME
);


--for custom columns
select lower(stmnt) from (
select 'function get_' || columns.table_name || '_4' -- change number here if you want multiple "getter" procedures
|| '('
|| LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.column_id)
|| ')'
|| ' return ' || columns.table_name || '%rowtype'
|| ' is ' || 'l_returnvalue ' || columns.table_name || '%rowtype;'
|| 'begin select * into l_returnvalue from ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.column_id) || ';'
|| 'return l_returnvalue;'
|| 'exception when no_data_found then raise; when too_many_rows then raise; when others then raise; end get_' || columns.table_name || '_4;' -- change number here if you want multiple "getter" procedures
as stmnt
from user_tab_columns columns
where columns.table_name = 'SALARY_DATA'
and column_name in ('CASE_NUM', 'ID')
GROUP BY columns.TABLE_NAME
);


--custom columns AND rowid
select lower(stmnt) from (
select 'function get_' || columns.table_name || '_rowid4' -- change number here if you want multiple "getter" procedures
|| '('
|| ' p_rowid in rowid,'
|| LISTAGG('p_' || columns.COLUMN_NAME || ' IN ' || columns.table_name || '.' || columns.column_name || '%type', ',') WITHIN GROUP (ORDER BY columns.column_id)
|| ')'
|| ' return ' || columns.table_name || '%rowtype'
|| ' is ' || 'l_returnvalue ' || columns.table_name || '%rowtype;'
|| ' begin select * into l_returnvalue from ' || columns.table_name || ' WHERE ' || LISTAGG(columns.COLUMN_NAME || '=' || 'p_' || columns.COLUMN_NAME, ' and ') WITHIN GROUP (ORDER BY columns.column_id)
|| ' and rowid = p_rowid;'
|| 'return l_returnvalue;'
|| 'exception when no_data_found then raise; when too_many_rows then raise; when others then raise; end get_' || columns.table_name || '_rowid4;' -- change number here if you want multiple "getter" procedures
as stmnt
from user_tab_columns columns
where columns.table_name = 'SALARY_DATA'
and column_name in ('CASE_NUM', 'ID')
GROUP BY columns.TABLE_NAME
);
