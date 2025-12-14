create or replace package body qa_pkg
as
    procedure generate_pin_numbers(p_low in integer, p_high in integer)
	is
	begin
        execute immediate 'truncate table temp_pins drop storage';

        for i in 1..2 --to generate mix of 7 and 12 digit pins
        loop
            if math_pkg.is_even(i)
            then
                insert into temp_pins(
                    select trunc(dbms_random.value(1000000, 9999999)) as value
                    from dual
                    connect by level <= dbms_random.value(p_low, p_high)
                );
            else
                insert into temp_pins(
                    select trunc(dbms_random.value(100010000000, 100019999999)) as value
                    from dual
                    connect by level <= dbms_random.value(p_low, p_high)
                );
            end if;
            commit;
        end loop;
	end generate_pin_numbers;

end qa_pkg;	

