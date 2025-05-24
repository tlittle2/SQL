DECLARE
	type t_nums is table of PLS_INTEGER index by PLS_INTEGER;
	t_arr t_nums;
	
	type t_input is table of PLS_INTEGER;
	t_ip t_input := t_input(3,4,1,7,2); --ip from user

	minNum PLS_INTEGER;
	minKey PLS_INTEGER;


	procedure populateMap(p_ip IN t_input, p_arr IN OUT t_nums)
	is
	begin
	    for i in p_ip.FIRST..p_ip.LAST
	    loop
	        	p_arr(i) := p_ip(i);
	    end loop;
	end;
	
	FUNCTION returnAnswer(p_arr IN t_nums)
	return PLS_INTEGER
	is
	begin
		minNum := p_arr(t_arr.FIRST);
		minKey := p_arr.FIRST;
	
		for i in p_arr.FIRST..p_arr.LAST
		loop
	        	if p_arr(i) < minNum then
		        	minNum := t_arr(i);
		        	minKey := i;
			end if;
	    	end loop;
		return minKey-1;
	end;

BEGIN
	populateMap(t_ip, t_arr);
	dbms_output.put_line(returnAnswer(t_arr));

END;
