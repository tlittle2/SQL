DECLARE
  type t_arr is table of integer index by pls_integer;
	mstr t_arr := t_arr();

	ip_str integer := 1000000000; --user input
	ans boolean:= True;

	procedure createMasterList is
    begin
        for i in 1..length(ip_str) loop
		      mstr(i):= i;
		    end loop;
    end;

	procedure findDifference is --this could be a function...need to further investigate why it didn't work
    begin
        for i in 1..length(ip_str) loop
        if substr(ip_str, i, 1) <> mstr(i) then
        	ans:= False;
          exit;
        end if;
	end loop;
    end;
        

BEGIN
  createMasterList;
	findDifference;
	
	if ans then
    	dbms_output.put_line(substr(ip_str, length(ip_str)));
    else
        dbms_output.put_line(-1);
    end if;

END;
