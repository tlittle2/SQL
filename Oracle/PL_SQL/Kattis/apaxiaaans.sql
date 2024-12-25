DECLARE
  type v_arr is table of char(1);
	arr v_arr := v_arr();

	ip varchar2(32767) := 'rooobert';
	ans varchar(32767);

BEGIN
    for i in 1..length(ip) loop
    	arr.EXTEND;
		  arr(arr.LAST) := substr(ip, i, 1);
    end loop;

	for i in 1..arr.COUNT-1 LOOP
        if arr(i) <> arr(i+1) then
        ans:= ans || arr(i);
        end if;
    END LOOP;

	ans:= ans || arr(arr.LAST);

	dbms_output.put_line(ans);

END;
