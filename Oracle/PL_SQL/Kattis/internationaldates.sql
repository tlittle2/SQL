DECLARE
  ip varchar2(10) := '25/03/2023';

	v_part1 integer:= cast(substr(ip, 1, 2) as integer);
	v_part2 integer:= cast(substr(ip, 4, 2) as integer);
	v_year integer:= cast(substr(ip, 7, 4) as integer);
		
BEGIN
    if v_part1 > 12 then
    	dbms_output.put_line('EU');
	elsif v_part2 > 12 then
      dbms_output.put_line('US');
	else
      dbms_output.put_line('either');
	end if;

END;
