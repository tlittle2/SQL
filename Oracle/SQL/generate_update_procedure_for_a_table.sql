--generic update for all columns
select lower(stmnt) from (
select 'procedure update_' || tab.table_name
|| '_1(' || LISTAGG('p_' || tab.COLUMN_NAME || ' ' || tab.table_name || '.' || tab.column_name || '%type DEFAULT NULL', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID) || ')'
|| 'is begin UPDATE '
|| tab.table_name || ' set ' || LISTAGG(tab.COLUMN_NAME || ' = nvl(' ||'p_' || tab.COLUMN_NAME || ',' || tab.column_name || ')', ' , ') WITHIN GROUP (ORDER BY tab.COLUMN_ID)
|| '; end update_' || tab.table_name || ';' as stmnt
from user_tab_columns tab
where tab.table_name in ('SALARY_DATA_STG', 'ASTROLOGY', 'CONTROL_REPS')
GROUP BY tab.TABLE_NAME
);


--where clause (need to find away to isolate PK constraints only for this particular query)
with ds as (
SELECT
    tab.table_name   tbl
  , tab.column_name  AS tab_column
  , cons.column_name AS cons_column
  --, coalesce(cons.column_name , tab.column_name) as all_cols
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
|| LISTAGG('p_' || case when tab_column = cons_column then cons_column || ' ' || tbl || '.' || cons_column || '%type' else tab_column || ' ' || tbl || '.' || tab_column || '%type DEFAULT NULL' end, ' , ') WITHIN GROUP (ORDER BY rownum) || ')'
|| 'is begin'
|| ' UPDATE '
|| tbl || ' set ' || (select LISTAGG(tab_column || ' = nvl(' ||'p_' || tab_column || ',' || tab_column || ')' , ' , ') WITHIN GROUP (ORDER BY column_id) from ds where cons_column is null)
|| ' where ' || (select LISTAGG(cons_column || ' = p_' || cons_column , ' and ') WITHIN GROUP (ORDER BY column_id) from ds where cons_column is not null)
|| '; end update_' || tbl || ';' as stmnt
from ds ds
group by tbl
);

