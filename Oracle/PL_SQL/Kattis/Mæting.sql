DECLARE
	type table_t is table of integer;
	ip1 table_t := table_t(1,2,3);
	ip2 table_t := table_t(1,2,4);
	type ans_t is table of integer index by pls_integer;
	ans ans_t;
	idx integer:=1;
BEGIN
    for i in 1..ip1.COUNT loop
    	if ip1(i) member of ip2 then
    		ans(idx):=ip1(i);
			idx:= idx + 1;
		end if;
    end loop;

	for i in 1..ans.COUNT loop
        dbms_output.put_line(ans(i));
    end loop;

END;
