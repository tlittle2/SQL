with ip as(
    select 
      '1111' as str
    , '1234' as str2
    from dual
)
select power(2,sum(case when ip1 <> ip2 then 1 else 0 end)) from (
    select substr(str, level,1) as ip1
    ,  substr(str2, level,1) as ip2
    from ip
    connect by level <= length(str)
);
