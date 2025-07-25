--generic update for all columns
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '(' || LISTAGG('p_' || tab.COLUMN_NAME || ' ' || tab.table_name || '.' || tab.column_name || '%type DEFAULT NULL', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID) || ')'
|| 'is begin UPDATE '
|| tab.table_name || ' set ' || LISTAGG(tab.COLUMN_NAME || ' = nvl(' ||'p_' || tab.COLUMN_NAME || ',' || tab.column_name || ')', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID)
|| '; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);


--Kinda close for adding a where claused based on constraints on a table (could be used for primary key constraints, indexes, partitions)
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '(' || LISTAGG('p_' || tab.COLUMN_NAME || ' ' || tab.table_name || '.' || tab.column_name || '%type DEFAULT NULL', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID) || ')'
|| 'is begin UPDATE '
|| tab.table_name || ' set ' || LISTAGG(tab.COLUMN_NAME || ' = nvl(' ||'p_' || tab.COLUMN_NAME || ',' || tab.column_name || ')', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID)
|| ' WHERE ' || columns.column_name || '= p_' || columns.column_name
|| '; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
inner join user_constraints constraints
on tab.table_name  = constraints.table_name
inner join user_cons_columns columns
on constraints.table_name  = columns.table_name
and constraints.constraint_name = columns.constraint_name
where constraints.constraint_type = 'P'
and tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME, columns.column_name
);
