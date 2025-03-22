/*not working currently*/
with ip as(
    select 
      '4 4 3 4' as str1

    from dual
)

        select EXP(SUM(LOG(ip1))) AS product from (
        select rownum as rn
        , to_number(regexp_substr(str1, '\S+',1, LEVEL)) as ip1
        from ip
        connect by level <= regexp_count(str1, '\S+')
        ) where rn in (1,3)
;
