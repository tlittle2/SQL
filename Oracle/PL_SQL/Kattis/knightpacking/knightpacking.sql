DECLARE    
	ip number := 1;

	function answer(p_ip number) return VARCHAR2 is
	begin
	        if mod(p_ip, 2) = 1 then
	    		return 'first';
	    	else
			return 'second';
	    	end if;
    	end;
BEGIN
    dbms_output.put_line(answer(ip));
END;
