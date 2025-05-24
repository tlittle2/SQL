DECLARE    
	type t_arr is table of number;
	arr t_arr := t_arr();

	subtype max_varchar2 is varchar2(32767);
	ip_str max_varchar2 := 'yesterdayihad1001,BUTnowihave9999'; --user input
	num_match max_varchar2;
	currMax integer:= -1;

	procedure processInput
	is
	begin
	        for i in 1..REGEXP_COUNT(ip_str, '\d+')
		loop
		    	num_match := REGEXP_SUBSTR(ip_str, '\d+', 1, i);
		    	if num_match is not null then
				arr.EXTEND;
		    		arr(arr.COUNT):= to_number(num_match);
			end if;
	    	end loop;
    	end;
BEGIN
	processInput;
	for i in arr.FIRST..arr.LAST loop
        	currMax:= greatest(currMax, arr(i));
    	end loop;

	dbms_output.put_line(currMax);
END;
