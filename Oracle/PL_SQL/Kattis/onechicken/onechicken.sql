DECLARE
	ip varchar(9) := '20 100';

	n integer:= to_number(substr(ip, 1, instr(ip, ' ')-1));
	m integer:= to_number(substr(ip, instr(ip, ' ')+1, length(ip)));
			
BEGIN
	if n < m then
    		if m - n = 1 then
    			dbms_output.put_line('Dr. Chaz will have '|| (m-n) || ' piece of chicken left over!');
		else
            		dbms_output.put_line('Dr. Chaz will have '|| (m-n) || ' pieces of chicken left over!');
        	end if;
	else
		if n - m = 1 then
    			dbms_output.put_line('Dr. Chaz needs '|| (n-m) || ' more piece of chicken!');
		else
            		dbms_output.put_line('Dr. Chaz needs '|| (n-m) || ' more pieces of chicken!');
        	end if;
    	end if;
END;
