DECLARE    
	type t_arr is table of integer;
	t_values t_arr := t_arr(0,2,104,117);

	running boolean:= False;
	total integer:= 0;
	lastTime integer:= t_values(t_values.FIRST);

BEGIN
    for i in t_values.FIRST..t_values.LAST loop
    	if not running then
        running := True;
        lastTime:= t_values(i);
		else
        running := False;
			  total:= total + t_values(i) - lastTime;
		end if;
	end loop;

	if running then
    dbms_output.put_line('still running');
  else
		dbms_output.put_line(total);
    end if;
            
END;
