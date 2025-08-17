with ip as(
    select 'ahhhhhh' as ip1, 'aahh' as ip2 from dual
    
)

select 
case when ip1 >= ip2 then 'go' else 'no' end as answer
from ip;
