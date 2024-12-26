CREATE OR REPLACE PROCEDURE PROC_PANAGRAM(p_inputString VARCHAR2) as
	type char_arr_t is table of char(1);
	c_arr char_arr_t:= char_arr_t();
	ip_arr char_arr_t:= char_arr_t();

procedure getSetOfCharacters(p_chrset IN OUT char_arr_t) is
    begin
        for i in ascii('a')..ascii('z') loop --97-122
    	p_chrset.EXTEND;
	p_chrset(i - ascii('a') + 1):= chr(i); --indices 1-26
	end loop;
    end;

procedure processInput(p_ipString IN VARCHAR2, p_c_arr IN char_arr_t, p_ip_arr IN OUT char_arr_t) is 
    begin
        for i in 1..length(p_ipString) loop
        if lower(substr(p_ipString, i, 1)) member of p_c_arr then
        	p_ip_arr.EXTEND;
    		p_ip_arr(p_ip_arr.LAST):= lower(substr(p_ipString, i, 1));
		end if;
	end loop;
    end;

function computeMissing(p_c_arr IN char_arr_t, p_ip_arr IN char_arr_t) return varchar2 is
    p_outString varchar2(26);
    BEGIN    
        for i in p_c_arr.FIRST..p_c_arr.LAST loop
        if p_c_arr(i) not member of p_ip_arr then
        p_outString:= p_outString || p_c_arr(i);
        end if;
	end loop;
	
	return p_outString;
    END;

function isPanagram(p_ip_string VARCHAR2) RETURN VARCHAR2 IS
    BEGIN
        if length(p_ip_string) is null then
	RETURN 'pangram';
    	else
        RETURN 'missing ' || p_ip_string;
	end if;
    END;

BEGIN
  	getSetOfCharacters(c_arr);
	processInput(p_inputString,c_arr,ip_arr);
	dbms_output.put_line(isPanagram(computeMissing(c_arr, ip_arr)));
END;
