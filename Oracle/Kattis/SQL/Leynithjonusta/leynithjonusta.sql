with ip as(
    select 
      'keppnis forritun @ g mail . com' as str1
    from dual
)
    select replace(str1, ' ', '') from ip
;
