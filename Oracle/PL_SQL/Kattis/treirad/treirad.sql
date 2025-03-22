DECLARE
	ip integer:= 1234;
	strt integer:= 1;
	cnt integer:=0;		

BEGIN
	loop
		exit when strt * (strt + 1) * (strt + 2) >= ip;
      		cnt:= cnt+1;
  	  	strt:= strt+1;
	end loop;

	dbms_output.put_line(cnt);
	
END;
