with ds as(
    select 
    substr(upper(trim(text)), 1, instr(upper(trim(text)), ' ')-1) as pl_type
    , trim(
        substr(
            upper(trim(text)),
            instr(upper(trim(text)), ' '),
            decode(
                instr(upper(trim(text)), ';'), 0, length(upper(trim(text))), instr(upper(trim(text)), ';')
            ) - instr(upper(trim(text)), ' ')
        )
    )
    as module
    , a.* from user_source a
    where upper(name) = upper('DATE_UTILS_PKG') and
    type = 'PACKAGE BODY'
)

, format_output as (
    select
    case when rn = 1 then module else null end as mo,
      n.*
    from(
        select decode(pl_type, 'FUNCTION', 1, 'PROCEDURE', 1, 2) as rn,
        --row_number() over (partition by case when pl_type in('FUNCTION', 'PROCEDURE') then d.module else null end order by line) as rn,
        d.*
        from ds d
        order by line
    )n
)

, code_mp as (
    select last_value(mo ignore nulls) over (order by line asc rows between unbounded preceding and current row) as cde,
    a.* from format_output a
    order by line asc
)

select substr(cde, 1, decode(instr(cde, '('), 0, length(cde),instr(cde, '(')-1)) as module
, line
, text
from code_mp a;
