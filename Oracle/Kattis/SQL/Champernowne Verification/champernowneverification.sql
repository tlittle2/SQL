with ip as(
    select '123456789' as ip1 from dual
    
)

select decode(min(ans), -1, -1, max(ans)) as answer from (
    select rn, ip1, val, case when rn = val then rn else -1 end as ans from (
        select rownum as rn, ip1, to_number(substr(ip1, level, 1)) as val
        from ip 
        connect by level <= length(ip1)
    )
);
