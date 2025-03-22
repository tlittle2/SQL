with ip as(
    select 
      'pogger' as str1
    , 'pepega' as str2
    from dual
)
    select sum(case when ip1 <> ip2 then 1 else 0 end)+1 as answer from (
    select substr(str1, level,1) as ip1
    ,  substr(str2, level,1) as ip2
    from ip
    connect by level <= length(str1)
    )
;
