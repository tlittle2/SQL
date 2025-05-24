DECLARE
	type vowelList is table of char(1);
	vowels vowelList := vowelList('A','E','I','O','U');
	ip char(1):= 'A';

BEGIN
	if ip member of vowels
	then
    		dbms_output.put_line('Jebb');
	else
    		if ip = 'Y'
		then
      			dbms_output.put_line('Kannski');
    		else
      			dbms_output.put_line('Neibb');
    		end if;
  	end if;
END;
