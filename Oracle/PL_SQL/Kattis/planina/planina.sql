DECLARE
  type t_arr is table of integer;
	numbers t_arr := t_arr(1,7,20,9);
	ip1 integer:= 5; --user input 1
	ans integer:= power((power(2, ip1)+1),2);

BEGIN    
    dbms_output.put_line(ans);
END;
