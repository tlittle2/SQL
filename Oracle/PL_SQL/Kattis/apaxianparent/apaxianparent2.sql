DECLARE
	mx_len CONSTANT NUMBER := 20;
	subtype io_str_st is varchar2(mx_len);
	subtype kp_str_st is varchar2(mx_len/2);

	type t_chars is table of char(1);
	vowels t_chars := t_chars('a','e','i','o', 'u');

	ipString io_str_st := 'andrex naxos';
	
	kid kp_str_st:= substr(ipString, 1, instr(ipString, ' ')-1);
	parent kp_str_st := substr(ipString, instr(ipString, ' ')+1, length(ipString));

	outString io_str_st;
	
BEGIN
	dbms_output.put_line(kid);
	dbms_output.put_line(parent);
	case
	    	when substr(kid, length(kid),1) = 'e' then outString := kid || 'x' || parent;
		when substr(kid, length(kid)-1,2) = 'ex' then outString := kid || parent;
		when substr(kid, length(kid),1) member of vowels then outString:= substr(kid, 1,length(kid)- 1) || 'ex' || parent;
		else outString := kid || 'ex' || parent;
  	end case;

	dbms_output.put_line(outString);
END;
