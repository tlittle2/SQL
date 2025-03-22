DECLARE
	ip varchar2(100) := 'THIS IS A LONGER, MORE EXPENSIVE LINE.';

	type arr_t is table of char(1);

	arr arr_t;

	cost NUMBER := 0;

	TYPE T_COST_MAP IS TABLE OF PLS_INTEGER INDEX BY VARCHAR2(1);
	cost_map CONSTANT T_COST_MAP := T_COST_MAP(
	'!' => 9
	, '''' => 6
	,'#' => 24
	,'$' => 29
	,'%' => 22
	,'&' => 24
	,',' => 3
	,'(' => 12
	,')' => 12
	,'*' => 17
	,'+' => 13
	,',' => 7
	,'-' => 7
	,'.' => 4
	,'/' => 10
	,'0' => 22
	,'1' => 19
	,'2' => 22
	,'3' => 23
	,'4' => 21
	,'5' => 27
	,'6' => 26
	,'7' => 16
	,'8' => 23
	,'9' => 26
	,':' => 8
	,';' => 11
	,'<' => 10
	,'=' => 14
	,'>' => 10
	,'?' => 15
	,'@' => 32
	,'A' => 24
	,'B' => 29
	,'C' => 20
	,'D' => 26
	,'E' => 26
	,'F' => 20
	,'G' => 25
	,'H' => 25
	,'I' => 18
	,'J' => 18
	,'K' => 21
	,'L' => 16
	,'M' => 28
	,'N' => 25
	,'O' => 26
	,'P' => 23
	,'Q' => 31
	,'R' => 28
	,'S' => 25
	,'T' => 16
	,'U' => 23
	,'V' => 19
	,'W' => 26
	,'X' => 18
	,'Y' => 14
	,'Z' => 22
	,'[' => 18
	,'\' => 10
	,']' => 18
	,'^' => 7
	,'_' => 8
	,'`' => 3
	,'a' => 23
	,'b' => 25
	,'c' => 17
	,'d' => 25
	,'e' => 23
	,'f' => 18
	,'g' => 30
	,'h' => 21
	,'i' => 15
	,'j' => 20
	,'k' => 21
	,'l' => 16
	,'m' => 22
	,'n' => 18
	,'o' => 20
	,'p' => 25
	,'q' => 25
	,'r' => 13
	,'s' => 21
	,'t' => 17
	,'u' => 17
	,'v' => 13
	,'w' => 19
	,'x' => 13
	,'y' => 24
	,'z' => 19
	,'{' => 18
	,'|' => 12
	,'}' => 18
	,'~' => 9
	,' ' => 0
	);

	procedure populateCollection(p_ipString IN VARCHAR2, p_collection IN OUT arr_t) is
	begin
		p_collection := arr_t();
		for i in 1..length(p_ipString)
		loop
			p_collection.EXTEND;
			p_collection(i):= substr(p_ipString, i, 1);
		end loop;
	end;

BEGIN
	populateCollection(ip,arr);
	for i in arr.FIRST..arr.LAST
	loop
        	cost:= cost + cost_map(arr(i));
    	end loop;

	dbms_output.put_line(cost);

END;
