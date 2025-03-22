with ip1 as(
    select 1 as ip1_ip from dual union all
    select 4 from dual union all
    select 3 from dual union all
    select 2 from dual union all
    select 5 from dual union all
    select 8 from dual union all
    select 7 from dual union all
    select 6 from dual
    
)
,ip2 as(
    select 9 as ip2_ip from dual union all
    select 1 from dual UNION ALL
    select 7 from dual UNION ALL
    select 8 from dual UNION ALL
    select 3 from dual UNION ALL
    select 2 from dual UNION ALL
    select 4 from dual
    
)

select listagg(ip1_ip, ' ') WITHIN GROUP (order by rownum asc) as answer
from ip1
inner join ip2
on ip1.ip1_ip = ip2.ip2_ip
;
