with ip as(
    select 'hellohrllohello' as ip1 from dual
    
)
select diffStr as answer from (
    select 
    substr(ip1, level, floor(length(ip1)/3)) as diffStr
    from ip
    connect by level <= length(ip1)
)ds inner join ip
on substr(ds.diffStr, 1, 1) = substr(ip.ip1, 1, 1)
group by diffStr having count(diffStr) > 1
;
