select case when s_order = 2 and nxt = 3 then substr(stmnt, 1, length(stmnt) -1) else stmnt end as stmnt from (
select s_order, lead(s_order, 1) over (order by table_name,s_order asc) as nxt, lower(stmnt) as stmnt from (
select distinct 1 as s_order, table_name, 'type ' || lower(table_name) || '_tapi_rec is record(' as stmnt, 0 as column_id
from user_tab_columns where table_name in ('SALARY_DATA', 'INFA_GLOBAL') 
union all
select 2 as s_order, table_name, lower(column_name) || ' ' || concat(lower(table_name || '.' || column_name), '%type')  || ',', column_id
from user_tab_columns where table_name in ('SALARY_DATA', 'INFA_GLOBAL') 
union all
select distinct 3 as s_order, table_name, ');', 32767 as column_id
from user_tab_columns where table_name in ('SALARY_DATA', 'INFA_GLOBAL') 
union all
select distinct 4 as s_order,table_name, 'type ' || lower(table_name) || '_tapi_tab is table of ' ||lower(table_name) || '_tapi_rec' as stmnt, 32767 * 2 as column_id
from user_tab_columns where table_name in ('SALARY_DATA', 'INFA_GLOBAL') 
) order by table_name, s_order, column_id asc
);
