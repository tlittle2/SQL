DECLARE
	type t_arr is table of integer index by pls_integer;
	ip_str integer := 1000000000; --user input
	
	function createMasterList
	return t_arr
	is
        	mstr t_arr := t_arr();
    	begin
	        for i in 1..length(ip_str) loop
			mstr(i):= i;
		end loop;
		
		return mstr;
    	end;

	function findDifference(p_mstr t_arr)
	return BOOLEAN
	is
    	begin
	        for i in 1..length(ip_str) loop
		        if substr(ip_str, i, 1) <> p_mstr(i)
			then
		        	return False;
		        	exit;
		        end if;
		end loop;
		
		return True;
    	end;

BEGIN
	if findDifference(createMasterList)
	then
    		dbms_output.put_line(substr(ip_str, length(ip_str)));
    	else
        	dbms_output.put_line(-1);
	end if;

END;
