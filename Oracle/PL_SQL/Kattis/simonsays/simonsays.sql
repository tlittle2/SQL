DECLARE
	type v_arr is table of varchar2(100);
	arr v_arr := v_arr('Raise your right hand.','Lower your right hand.','Simon says raise your left hand.');
	saying char(10) := 'Simon says';

BEGIN
	for i in 1..arr.COUNT
	loop
		if instr(arr(i), saying) > 0
		then
			dbms_output.put_line(substr(arr(i), instr(arr(i) , saying) + length(saying), length(arr(i))));
    		end if;
    	end loop;
END;
