DECLARE
	type t_arr is table of integer;
	arr t_arr := t_arr(1,7,383,1000); --user input simulation

	function isPrime(p_prime in integer)
	return boolean
	is
  		function f_prime(p_prime in number, p_divisor in number)
		return number
		is
  		begin
    			return case when p_divisor >= p_prime then 0 else case when mod(p_prime, p_divisor) = 0 then 1 else 0 end + f_prime(p_prime, p_divisor+1) end;
  		end;
	begin
  		if f_prime(p_prime, 2) > 0 or p_prime = 1 then
        		return False;
		else
            		return True;
		end if;
	end;

	FUNCTION isHappy(n integer)
	return boolean
	is
	    	ans integer:= 0;
		str_n varchar2(20):= to_char(n);
	begin
	        if n = 1 then
			return False;
	        end if;
	
		for i in 1..length(str_n) --square each digit in the number and add to the result
		loop
			ans:= ans + POWER(TO_NUMBER(SUBSTR(str_n, i, 1)), 2);
	        end loop;
					
		if length(to_char(ans)) = 1 then
			if ans in (1,7) then
	        	return True;
			else
	        	return False;
			end if;
		else
			return isHappy(ans); --recurse until the string length of the answer is 1
	    	end if;
	end;
	
BEGIN
    for i in arr.FIRST..arr.LAST
    LOOP
        if isHappy(arr(i)) and isPrime(arr(i))
	then
        	dbms_output.put_line(arr(i) || ' YES');
    	else
		dbms_output.put_line(arr(i) || ' NO');
        end if;
    END LOOP;
END;
