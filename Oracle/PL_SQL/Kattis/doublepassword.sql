DECLARE
	type arr_t is table of varchar2(4);
	arr1 arr_t:= arr_t();
	arr2 arr_t:= arr_t();
    
	ip1 varchar(4) := '1111';
	ip2 varchar(4) := '1234';

	c integer:= 0;

BEGIN
    for i in 1..length(ip1) loop
    	arr1.EXTEND;
		arr1(i):= substr(ip1, i, 1);
    end loop;

	for i in 1..length(ip2) loop
    	arr2.EXTEND;
		arr2(i):= substr(ip2, i, 1);
    end loop;

	for i in 1..arr1.COUNT loop
        if arr1(i) <> arr2(i) then
        c:= c + 1;
		end if;
    end loop;

	dbms_output.put_line(power(2,c));

END;
