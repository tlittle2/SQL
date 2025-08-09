--======================================================generic update nvl based on %rowtype======================================================

select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_row(p_row IN ' || tab.table_name || '%rowtype)'
|| 'is begin UPDATE '
|| tab.table_name || ' set ' || LISTAGG(tab.COLUMN_NAME || ' = nvl(' ||'p_row.' || tab.COLUMN_NAME || ',' || tab.column_name || ')', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID)
|| '; exception when others then raise; end update_' || tab.table_name || '_row;' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);

select case when s_order = 2 and nxt = 3 then substr(stmnt, 1, length(stmnt) -1) else stmnt end as stmnt from (
select s_order, lead(s_order, 1) over (order by table_name,s_order asc) as nxt, lower(stmnt) as stmnt from (
select 1 as s_order, table_name as table_name, null as column_name, 0 as column_id, 'procedure update_' || tab.table_name|| '_row(p_row IN ' || tab.table_name || '%rowtype)'|| 'is begin UPDATE '|| tab.table_name || ' set ' as stmnt
from user_tables tab

union all

select 2 as s_order, table_name as table_name, column_name as column_name, column_id as column_id, column_name || ' = nvl(' ||'p_row.' || tab.COLUMN_NAME || ',' || tab.column_name || '),' stmnt
from user_tab_columns tab

union all

select 3 as s_order, table_name as table_name, null as column_name, 32767 as column_id, '; exception when others then raise; end update_' || tab.table_name || '_row;' as stmnt
from user_tables tab
)order by table_name, s_order, column_id
);

--======================================================generic update nvl based on %rowtype======================================================



--======================================================update set row based on rowid given a %rowtype ======================================================
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_rowid( p_rowid IN rowid, p_row IN ' || tab.table_name || '%rowtype)'
|| 'is begin UPDATE '
|| tab.table_name || ' set row = p_row'
|| ' where rowid = p_rowid'
|| '; exception when others then raise; end update_' || tab.table_name || ';' as stmnt
from user_tables tab
);

--======================================================update set row based on rowid given a %rowtype ======================================================




--======================================================generic update based on pl/sql row (update table set row = p_row)======================================================

select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_row(p_row IN ' || tab.table_name  || '%rowtype)'
|| 'is begin UPDATE '
|| tab.table_name || ' set row = p_row' 
|| '; exception when others then raise; end update_' || tab.table_name || '_row;' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);

--======================================================generic update based on pl/sql row (update table set row = p_row)======================================================
