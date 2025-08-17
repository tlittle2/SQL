DECLARE
    type nest_t is table of varchar2(100);
    cities nest_t := nest_t('edmonton','edmonton','edmonton');
    city_set nest_t:= set(cities); --this allows to you get distinct values from nested tables

BEGIN
    for i in 1..city_set.COUNT
    loop
        dbms_output.put_line(city_set(i));
    end loop;
END;
