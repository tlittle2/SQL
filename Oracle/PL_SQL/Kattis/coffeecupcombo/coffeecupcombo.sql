DECLARE
  ip varchar2(10):= '1100000000';
	ans INTEGER:= 0;
	tempSum INTEGER:= 0;

BEGIN
    for i in 1..length(ip) loop
    	if substr(ip, i, 1) = '1' then
    		tempSum := 2;
			ans := ans + 1;
    	else
            if tempSum > 0 then
            ans := ans + 1;
			tempSum := tempSum -1;
            end if;
    	end if;
    end loop;

	dbms_output.put_line(ans);

END;
