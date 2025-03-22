with ip as(
    select 
      3 as ip1
    from dual
)
    select decode(mod(ip1,2), 1, 'first', 'second')
    from ip
;
