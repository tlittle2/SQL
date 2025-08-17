with ip as(
    select 'B' as ip1 from dual
    
)
    select ip1
    , case when ip1 in ('A','E','I','O','U') then 'Jebb'
    else
        decode(ip1, 'Y', 'Kannski', 'Neibb')
    end as answer
    from ip;
