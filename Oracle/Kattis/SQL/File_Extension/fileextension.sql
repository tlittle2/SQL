with ds as(

select 'model.blend' as word from dual
)

select reverse(substr(reverse(word), 1, instr(reverse(word), '.')))
--, word
from ds;
