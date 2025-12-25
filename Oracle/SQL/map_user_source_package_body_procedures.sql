with ds as (
    select case when regexp_like(upper(trim(text)), '(^PROCEDURE|^FUNCTION|^PACKAGE)') then 1 else 2 end as rn
    , upper(trim(text)) as txt
    --row_number() over (partition by case when pl_type in('FUNCTION', 'PROCEDURE') then d.module else null end order by line) as rn,
    , d.*
    from user_source d
    where upper(name) = upper('salary_data_tapi') and
    type = 'PACKAGE BODY'
    order by line
)

, formatted as (
    select rn
    , case when rn = 1 then substr(txt, 1, decode(instr(txt, '('), 0, length(txt),instr(txt, '(')-1)) else null end as header
    , text
    , line
    from ds
)

select * from (
    select last_value(header ignore nulls) over (order by line asc rows between unbounded preceding and current row) as mapping
    , a.*
    from formatted a
)--where mapping is not null
;

