DECLARE
	type arr_t is table of varchar2(4);
	arr1 arr_t:= arr_t();
	arr2 arr_t:= arr_t();
    
	ip1 varchar(4) := '1111';
	ip2 varchar(4) := '1234';

	c integer:= 0;

	procedure appendToCollection(p_collection IN OUT arr_t, p_str IN VARCHAR2) is 
    	begin
	        for i in 1..length(p_str) loop
	    	p_collection.EXTEND;
			p_collection(i):= substr(p_str, i, 1);
	    	end loop;

    	end;
        

BEGIN
	appendToCollection(arr1, ip1);
	appendToCollection(arr2, ip2);
	for i in 1..arr1.COUNT loop
        if arr1(i) <> arr2(i) then
        c:= c + 1;
		end if;
    	end loop;

	dbms_output.put_line(power(2,c));
END;
