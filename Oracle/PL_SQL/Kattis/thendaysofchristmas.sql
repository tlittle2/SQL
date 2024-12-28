DECLARE
	type t_arr is table of integer index by pls_integer;
	arr t_arr := t_arr();
	ip integer:= 12;

	out1 integer:= 0;
	out2 integer:= 0;

	PROCEDURE processInput is
    	begin
    		for i in 1..ip loop
        		arr(i):= i;
        	end loop;
    	end;

	PROCEDURE calculateOutput1 is
    	begin
        	for i in arr.first..arr.last loop
			out1:= out1 +arr(i);
		end loop;
    	end;

	PROCEDURE calculateOutput2 is
    	begin
        	for i in 1..ip loop
	        	for j in 1..i loop
    				out2:= out2 + j;
        		end loop;
    		end loop;
    	end;
    
BEGIN
	processInput;
	calculateOutput1;
    	calculateOutput2;	
	dbms_output.put_line(out1 || ' ' || out2);
END;
