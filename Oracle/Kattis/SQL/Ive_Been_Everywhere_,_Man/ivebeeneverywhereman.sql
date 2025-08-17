with ip as(
    select 'saskatoon' as ip1 from dual union all
    select 'toronto' from dual union all
    select 'winnipeg' from dual union all
    select 'toronto' from dual union all
    select 'vancouver' from dual union all
    select 'saskatoon' from dual union all
    select 'toronto' from dual
    
)

select count(distinct ip1)
from ip
;
