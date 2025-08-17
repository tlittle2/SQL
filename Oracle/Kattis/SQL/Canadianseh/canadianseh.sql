with ip as(
    select 
      'Im not suspicious, Eh?' as str1
    from dual
)
    select case when substr(str1, -3) = 'eh?'
    then 'Canadian!'
    else 'Imposter!'
    end as answer
    from ip
;
