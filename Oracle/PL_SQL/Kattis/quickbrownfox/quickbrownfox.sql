
DECLARE
	type char_arr_t is table of varchar(1);
	c_arr char_arr_t:= char_arr_t();
	ip_arr char_arr_t:= char_arr_t();
	missing varchar(26);

	ip varchar2(100) := 'The quick brown fox jumps over the lazy dog.'; --input

BEGIN
	--get set of all lower case letters(ascii 97-122)
	for i in ascii('a')..ascii('z')
	loop
		c_arr.EXTEND;
		c_arr(i - ascii('a') + 1):= chr(i); --indices 1-26
	end loop;

	--add all characters from input to nested table
	for i in 1..length(ip)
	loop
        	if lower(substr(ip, i, 1)) member of c_arr
		then
	        	ip_arr.EXTEND;
	    		ip_arr(ip_arr.LAST):= lower(substr(ip, i, 1));
		end if;
	end loop;


	--see what letters are missing
	for i in 1..c_arr.COUNT
	loop
	        if c_arr(i) not member of ip_arr
		then
		        missing:= missing || c_arr(i);
	        end if;
	end loop;

	--return if it's a panagram or not
	if length(missing) is null
	then
		dbms_output.put_line('pangram');    
    	else
        	dbms_output.put_line('missing ' || missing);
	end if;
END;
