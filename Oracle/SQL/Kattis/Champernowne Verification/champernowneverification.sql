with ip as(
    select '1000000000' as ip1 from dual
    
)

select case when min(ans) = -1 then -1 else max(ans) end as answer from (
    select rn, ip1, val, case when rn = val then rn else -1 end as ans from (
        select rownum as rn, ip1, to_number(substr(ip1, level, 1)) as val
        from ip 
        connect by level <= length(ip1)
    )
);
