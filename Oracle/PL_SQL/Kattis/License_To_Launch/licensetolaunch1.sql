DECLARE
	type t_nums is table of PLS_INTEGER index by PLS_INTEGER;
	t_arr constant t_nums:= t_nums(
        1 => 3,
        2 => 4,
        3 => 1,
        4 => 7,
        5 => 2
    );

	minNum PLS_INTEGER;
	minKey PLS_INTEGER;

BEGIN

	minNum := t_arr(t_arr.FIRST);
	minKey := t_arr.FIRST;

	for i in t_arr.FIRST..t_arr.LAST
    	loop
        	if t_arr(i) < minNum then
	        	minNum := t_arr(i);
	        	minKey := i;
		end if;
    	end loop;

	dbms_output.put_line(minKey-1);

END;
