DECLARE
	subtype ipLength is varchar2(99);
	type t_arr is table of ipLength index by pls_integer;
	arr t_arr := t_arr();

	ip ipLength := 'hellohrllohello';
	len integer := 1;
	maxlength integer := floor(length(ip)/3);

	type c_arr is table of integer index by ipLength;
	occur c_arr := c_arr();

	tmpKey ipLength;
	procedure processInput(a IN OUT t_arr) is
    	begin
		for i in 1..3
		loop
			a(i) := substr(ip, len, maxlength);
			len := len + maxlength;
    		end loop;
    	end;

	procedure createOccurrenceArray(a IN t_arr, occurArray IN OUT c_arr) IS
	BEGIN
	        for i in a.FIRST..a.LAST
		loop
		        if occurArray.EXISTS(arr(i))then
		        	occurArray(arr(i)) := occurArray(arr(i)) + 1;
		        else
		        	occurArray(arr(i)) := 1;
			end if;
	    	end loop;
    	END;

	procedure findAnswer(occurArray IN c_arr) is
	begin
		tmpKey := occur.FIRST;
		while tmpKey is not null
		loop
			if occurArray(tmpKey) > 1 then
	            		dbms_output.put_line(tmpKey);
	    			exit;
            		end if;
    			tmpKey := occurArray.NEXT(tmpKey);
        	end loop;
    	end;
BEGIN
	processInput(arr);
	createOccurrenceArray(arr, occur);
	findAnswer(occur);
END;
