with ip as(
    select 
      0 as ip1
     ,0 as ip2
    from dual
)

    select case when ans = 0 then 'Not a moose'
        when ip1 = ip2 then 'Even ' || ans
        else 'Odd ' || ans
        end as answer
        from (
            select 
            ip1
            , ip2
            , greatest(ip1,ip2) * 2 as ans
            from ip
        )
;
