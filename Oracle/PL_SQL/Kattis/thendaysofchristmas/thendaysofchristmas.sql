DECLARE    
	type t_arr is table of integer index by pls_integer;
	arr t_arr;
	
	ip integer:= 12; --user input

	PROCEDURE processInput(p_ipString IN INTEGER, p_collection IN OUT t_arr) is
	begin
	        for i in 1..p_ipString
		loop
	        	p_collection(i):= i;
	        end loop;
    	end;

	FUNCTION calculateOutput1(p_collection IN t_arr) return INTEGER IS
    	out1 integer:= 0;
    	begin
        	for i in p_collection.FIRST..p_collection.LAST
		loop
			out1:= out1 + p_collection(i);
		end loop;
		
		return out1;
    	end;

	FUNCTION calculateOutput2(p_ipString IN INTEGER) return INTEGER IS
    	out2 integer:= 0;
    	begin
        	for i in 1..p_ipString
		loop
	        	for j in 1..i
			loop
    				out2:= out2 + j;
        		end loop;
    		end loop;
		return out2;
    	end;

BEGIN
	processInput(ip, arr);
	dbms_output.put_line(calculateOutput1(arr));
	dbms_output.put_line(calculateOutput2(ip));
END;
