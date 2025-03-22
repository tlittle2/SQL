DECLARE
	type v_arr is table of integer;
	ip_arr v_arr := v_arr();

	cases integer := 6;
			
BEGIN
	for i in 1..cases
	loop
		ip_arr.EXTEND;
		ip_arr(i):= dbms_random.value(1,10000);
    	end loop;

	for i in 1..ip_arr.COUNT
	loop
        	dbms_output.put_line(ip_arr(i) || '-> ' || length(ip_arr(i)));
    	end loop;
END;
