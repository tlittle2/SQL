DECLARE
	type t_arr is table of integer;
	numbers t_arr := t_arr(1,7,20,9);
	ip1 integer:= 2; --user input 1
	ip2 integer:= 3; --user input 2
	ans integer:= greatest(ip1,ip2) * 2;

BEGIN
	if ans = 0
	then
    		dbms_output.put_line('Not a moose');
    	elsif ip1 = ip2
	then
    		dbms_output.put_line('Even ' || ans);
	else
        	dbms_output.put_line('Odd ' || ans);
    	end if;
END;
