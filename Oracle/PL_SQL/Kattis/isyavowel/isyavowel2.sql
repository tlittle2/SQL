with ip as(
    select 
      'asdfiy' as str
    from dual
)
  
select 
sum(case when ip1 in ('a','e','i','o','u') then 1 else 0 end)
|| ' '
||  sum(case when ip1 in ('a','e','i','o','u', 'y') then 1 else 0 end)
as answer
from (
    select substr(str, level,1) as ip1
    from ip
    connect by level <= length(str)
);
