DECLARE
   type lst_t is table of varchar2(100);
   
   lst lst_t := lst_t(
   'Takatil',
   'Takatil',
   'Takatil',
   'Takatil',
   'Takatil'
   );
   
   lst2 lst_t := lst;
   
   l_set lst_t := lst multiset union distinct lst2;
   
BEGIN
    for i in l_set.first..l_set.last
    loop
        dbms_output.put_line(l_set(i));
    end loop;
    
END;
/
