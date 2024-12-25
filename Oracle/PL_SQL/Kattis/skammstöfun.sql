DECLARE
    type v_arr is table of char(1);
	arr v_arr := v_arr();

	ip varchar2(100) := 'Forritunarkeppni Framhaldsskolanna'; --user input
	ans varchar(100);

BEGIN
    for i in 1..length(ip) loop
    	arr.EXTEND;
		arr(arr.LAST) := substr(ip, i, 1);
    end loop;

	ans:= arr(1);
	for i in 1..arr.COUNT LOOP
        if arr(i) = ' ' then
        	if arr(i+1) = upper(arr(i+1)) then
        	ans:= ans || arr(i+1);
		end if;
        end if;
    END LOOP;

	dbms_output.put_line(ans);
END;
