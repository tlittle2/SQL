DECLARE
    type t_nums is table of PLS_INTEGER index by PLS_INTEGER;
	t_arr t_nums;

	minNum PLS_INTEGER;
	minKey PLS_INTEGER;

BEGIN
    t_arr(1) := 3;
    t_arr(2) := 4;
	t_arr(3) := 1;
	t_arr(4) := 7;
	t_arr(5) := 2;

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
