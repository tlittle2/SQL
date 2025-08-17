with ip as(
    select 12 as ip1 from dual
    
)
    select max(rollSum) as giftsReceived from (
    select sum(level) over (order by level) as rollSum
    from ip
    connect by level <= ip1
    );
