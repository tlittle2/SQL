
--======================================================generic update for all columns======================================================
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_1(' || LISTAGG('p_' || tab.COLUMN_NAME || ' IN ' || tab.table_name || '.' || tab.column_name || '%type DEFAULT NULL', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID) || ')'
|| 'is begin UPDATE '
|| tab.table_name || ' set ' || LISTAGG(tab.COLUMN_NAME || ' = nvl(' ||'p_' || tab.COLUMN_NAME || ',' || tab.column_name || ')', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID)
|| '; exception when others then raise; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);

select lower(stmnt) from (
select 1 as s_order, table_name as table_name, null as column_name, 0 as column_id, 'procedure update_' || tab.table_name|| '_row(p_row IN ' || tab.table_name || '%rowtype)'|| 'is begin UPDATE '|| tab.table_name || ' set ' as stmnt
from user_tables tab

union all

select 2 as s_order, table_name as table_name, column_name as column_name, column_id as column_id, column_name || ' = nvl(' ||'p_row.' || tab.COLUMN_NAME || ',' || tab.column_name || '),' stmnt
from user_tab_columns tab

union all

select 3 as s_order, table_name as table_name, null as column_name, 32767 as column_id, '; exception when others then raise; end update_' || tab.table_name || ';' as stmnt
from user_tables tab
)order by table_name, s_order, column_id;


--======================================================generic update for all columns======================================================

--update by rowid
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_rowid( p_rowid IN rowid, ' || LISTAGG('p_' || tab.COLUMN_NAME || ' IN ' || tab.table_name || '.' || tab.column_name || '%type DEFAULT NULL', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID) || ')'
|| 'is begin UPDATE '
|| tab.table_name || ' set ' || LISTAGG(tab.COLUMN_NAME || ' = nvl(' ||'p_' || tab.COLUMN_NAME || ',' || tab.column_name || ')', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID)
|| ' where rowid = p_rowid'
|| '; exception when others then raise; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);


--update rowid to parameter %rowtype 
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_rowid( p_rowid IN rowid, p_row IN ' || tab.table_name || '%rowtype)'
|| 'is begin UPDATE '
|| tab.table_name || ' set row = p_row'
|| ' where rowid = p_rowid'
|| '; exception when others then raise; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);



--where clause is primary key columns (with primary key columns at the front)
with ds as (
SELECT
    tab.table_name   tbl
  , tab.column_name  AS tab_column
  , cons.column_name AS cons_column
  , tab.column_id
from 
user_tab_columns tab
left outer join (select cons.table_name, cons.column_name from user_cons_columns cons inner join user_constraints constraints on cons.table_name = constraints.table_name and cons.constraint_name = constraints.constraint_name where constraints.constraint_type = 'P') cons
on tab.table_name = cons.table_name
and tab.column_name = cons.column_name
where tab.table_name = 'SALARY_DATA_STG'
order by case when cons.column_name is not null then 0 else 1 end asc nulls first, column_id
)

select lower(stmnt) as stmnt from (
select
'procedure update_' || tbl
|| '_2('
|| LISTAGG('p_' || case when tab_column = cons_column then cons_column || ' IN ' || tbl || '.' || cons_column || '%type' else tab_column || ' IN ' || tbl || '.' || tab_column || '%type DEFAULT NULL' end, ' , ') WITHIN GROUP (ORDER BY rownum) || ')'
|| 'is begin'
|| ' UPDATE '
|| tbl || ' set ' || (select LISTAGG(tab_column || ' = nvl(' ||'p_' || tab_column || ',' || tab_column || ')' , ' , ') WITHIN GROUP (ORDER BY rownum) from ds where cons_column is null)
|| ' where ' || (select LISTAGG(cons_column || ' = p_' || cons_column , ' and ') WITHIN GROUP (ORDER BY rownum) from ds where cons_column is not null)
|| '; exception when others then raise; end update_' || tbl || '_2;' as stmnt
from ds ds
group by tbl
);

--update based on pl/sql row (update table set row = p_row)
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_row(p_row IN ' || tab.table_name  || '%rowtype)'
|| 'is begin UPDATE '
|| tab.table_name || ' set row = p_row' 
|| '; exception when others then raise; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);


--update nvl based on %rowtype
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_row(p_row IN ' || tab.table_name || '%rowtype)'
|| 'is begin UPDATE '
|| tab.table_name || ' set ' || LISTAGG(tab.COLUMN_NAME || ' = nvl(' ||'p_row.' || tab.COLUMN_NAME || ',' || tab.column_name || ')', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID)
|| '; exception when others then raise; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);


