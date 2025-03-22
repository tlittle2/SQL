/*CLOSE. off by the last character*/
with ip as(
    select 'roooooobertapalaxxxxios' as str from dual
    
)

select listagg(nvl(prev,ip1), '') within group (order by rownum) as ans from (
    select lag(ip1) over(order by rownum) as prev, ip1 from (
        select substr(str, level,1) as ip1
        from ip
        connect by level <= length(str)
    )
) where ip1 <> nvl(prev,ip1)
;
