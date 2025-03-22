DECLARE
	type t_arr is table of integer;
	numbers t_arr := t_arr(1,7,20,9);
	sqrt_value number;
	ans varchar(2);

	FUNCTION isSquare(n INTEGER) RETURN BOOLEAN IS
    	sqrt_value number:= sqrt(n);
    	BEGIN
	        if trunc(sqrt_value) = sqrt_value then
	        return True;
	        end if;
	    	return False;
    	END;

	FUNCTION isOdd(n INTEGER) RETURN BOOLEAN IS
    	BEGIN
	        if mod(n,2) = 1 then
	        return True;
	        end if;
	    	return False;
    	END;

	PROCEDURE displayAnswer(str VARCHAR2) is
    	BEGIN
	        if length(str) > 0 then
	        dbms_output.put_line(ans);
			else
	        dbms_output.put_line('EMPTY');
	        end if;
		
		ans:= '';
	END;

BEGIN
	for i in numbers.FIRST..numbers.LAST
	loop
		if isOdd(numbers(i)) then
			ans:= ans || 'O';
		end if;
		
		if isSquare(numbers(i)) then
			ans:= ans || 'S';
        	end if;	
		displayAnswer(ans);
    	end loop;
END;
