DECLARE
	type v_arr is table of integer;
	compare v_arr := v_arr(4,3,2,7,6,5,4,3,2,1);
	ip_arr v_arr;
	ans_arr v_arr;

	ip varchar2(11):= '310111-0469'; --user input

	procedure processInput(p_ipString VARCHAR2, p_ipArr IN OUT v_arr) is
	begin
	    p_ipArr := v_arr();
	    for i in 1..length(p_ipString) loop
	    	if substr(p_ipString, i, 1) <> '-' then
		    p_ipArr.EXTEND;
		    p_ipArr(p_ipArr.LAST) := cast(substr(p_ipString, i, 1) as integer);
		end if;
	    end loop;
	end;
	
	procedure processAnswer(p_ipArr IN v_arr, p_ansArr IN OUT v_arr) is
	begin
	    p_ansArr := v_arr();
	    for i in 1..p_ipArr.COUNT loop
		p_ansArr.EXTEND;
		p_ansArr(p_ansArr.LAST) := p_ipArr(i) * compare(i);
	    end loop;
	end;
	
	function findFinal(p_ansArr IN v_arr) return integer is
	final integer := 0;
	begin
		for i in 1..ans_arr.COUNT
		LOOP
		final:= final +p_ansArr(i);
	    	end loop;
		return mod(final, 11);
	end;
	
BEGIN
	processInput(ip, ip_arr);
	processAnswer(ip_arr, ans_arr);

	if findFinal(ans_arr) = 0 then
        dbms_output.put_line(1);
	else
        dbms_output.put_line(0);
   	end if;

END;
