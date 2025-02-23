DECLARE
  type t_arr is table of char(1) index by pls_integer;
	positions t_arr := t_arr();

	subtype max_str_length is varchar2(1000);
	space_char CONSTANT char(1) := ' ';

	cnt integer := 0;

	ip_str max_str_length := 'foss<<rritun'; --user input
	ans max_str_length := '';
	

	function getCurrentChar(p_ip_str IN VARCHAR2, idx IN integer) return CHAR is
    begin
        return substr(p_ip_str,idx,1);
	end;
	
BEGIN
    for i in reverse 1..length(ip_str) loop
    	if getCurrentChar(ip_str, i) = '<' then
        	positions(i):= space_char;
			    cnt:= cnt+1;
		  elsif cnt > 0 then
          positions(i):= space_char;
			    cnt:= cnt-1;
		  else
          positions(i):= getCurrentChar(ip_str, i);
        end if;
    end loop;

	--dbms_output.put() was not working in oracle live sql, so i appended to a string
	for i in positions.FIRST..positions.LAST loop
        if positions(i) <> space_char then
        	ans:= ans || positions(i); 
		end if;
    end loop;
	dbms_output.put_line(ans);
END;
