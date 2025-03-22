DECLARE
	type t_input is table of char(1);
	t_ip1 t_input;
	t_ip2 t_input;

	ip1 varchar2(100) := 'pogger';
	ip2 varchar2(100) := 'pepega';


	procedure populateCollection(p_ipString IN VARCHAR2, p_collection IN OUT t_input) is
	begin
		p_collection := t_input();
		for i in 1..length(p_ipString)
	    	loop
			p_collection.EXTEND;
			p_collection(i) := substr(p_ipString, i, 1);
	    	end loop;
	end;
	
	function findDiffs(p_ip1 IN t_input, p_ip2 IN t_input) return PLS_INTEGER is
	diff PLS_INTEGER := 1;
	begin
		for i in p_ip1.FIRST..p_ip1.LAST
		loop
			if p_ip1(i) <> p_ip2(i) then
	        		diff := diff+1;
			end if;
	    	end loop;

		return diff;
	end;

BEGIN
	populateCollection(ip1, t_ip1);
	populateCollection(ip2, t_ip2);

	dbms_output.put_line(findDiffs(t_ip1, t_ip2));
END;
