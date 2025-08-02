with ds as(

select 'model.blend' as word from dual
)

select word, reverse(substr(reverse(word), 1, instr(reverse(word), '.'))) from ds;
