DECLARE    
	type t_arr is table of integer index by pls_integer;
	arr t_arr := t_arr();
	ip integer:= 12; --user input

	PROCEDURE processInput is
    	begin
    		for i in 1..ip loop
        		arr(i):= i;
        	end loop;
    	end;

	FUNCTION calculateOutput1(a IN t_arr) return INTEGER IS
    	out1 integer:= 0;
    	begin
        	for i in arr.first..arr.last loop
			out1:= out1 +arr(i);
		end loop;
		
		return out1;
    	end;

	FUNCTION calculateOutput2(a IN t_arr) return INTEGER IS
    	out2 integer:= 0;
    	begin
        	for i in 1..ip loop
	        	for j in 1..i loop
    				out2:= out2 + j;
        		end loop;
    		end loop;
		return out2;
    	end;
BEGIN
	processInput;
	dbms_output.put_line(calculateOutput1(arr) || ' ' || calculateOutput2(arr));
END;
