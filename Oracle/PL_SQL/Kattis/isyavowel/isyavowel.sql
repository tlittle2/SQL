DECLARE
	type t_arr is table of char(1);
	vowels t_arr := t_arr('a','e','i','o','u');
	word varchar2(50):= 'asdfiy';
	ans integer:= 0;
	ans2 integer;
BEGIN
    for i in 1..length(word) loop
    	if substr(word, i, 1) member of vowels then
    	ans:= ans + 1;
    	end if;
    end loop;
	ans2:= length(replace(word, 'y', '')) - ans;
	dbms_output.put_line(ans || ' ' || ans2);
END;
