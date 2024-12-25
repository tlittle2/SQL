    DECLARE
    	ip integer := 7; --value from standard input

    BEGIN
        if ip = 0 then
        	dbms_output.put_line(0);
        else
        	if ip <> 7 then
        	dbms_output.put_line(ip+1);
        	else
        	dbms_output.put_line(7);
        	end if;
        end if;
    
    END;
