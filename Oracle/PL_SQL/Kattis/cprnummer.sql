DECLARE
  type v_arr is table of integer;
	compare v_arr := v_arr(4,3,2,7,6,5,4,3,2,1);
	ip_arr v_arr := v_arr();
	ans_arr v_arr := v_arr();

	ip varchar2(11):= '051002-4321'; --user input
	final integer := 0;
	
BEGIN
     for i in 1..length(ip) loop
    	if substr(ip, i, 1) <> '-' then
        	ip_arr.EXTEND;
    		ip_arr(ip_arr.LAST) := cast(substr(ip, i, 1) as integer);
		end if;
    end loop;

	for i in 1..ip_arr.COUNT loop
		ans_arr.EXTEND;
		ans_arr(ans_arr.LAST) := ip_arr(i) * compare(i);
    end loop;

	for i in 1..ans_arr.COUNT LOOP
        final:= final +ans_arr(i);
    end loop;

	if mod(final, 11) = 0 then
        dbms_output.put_line(1);
	else
        dbms_output.put_line(0);
    end if;

END;
