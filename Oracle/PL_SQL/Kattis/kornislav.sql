DECLARE    
	type t_arr is table of number;
	ipArr t_arr := t_arr(4,4,3,4);

BEGIN
    dbms_output.put_line(ipArr(1) * ipArr(3));
    
END;
