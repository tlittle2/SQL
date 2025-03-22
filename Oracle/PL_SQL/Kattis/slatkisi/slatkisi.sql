DECLARE
	ipString varchar2(12) := '123450995 1';
  	price number:= to_number(substr(ipString, 1, instr(ipString, ' ')));
	zeros number:= to_number(substr(ipString, instr(ipString, ' '), length(ipString)));

	r varchar2(10) := 1;

BEGIN
	for i in 1..zeros
	loop
    		r := r || '0';
    	end loop;
	
  	dbms_output.put_line(round(price / r) * r);
END;
