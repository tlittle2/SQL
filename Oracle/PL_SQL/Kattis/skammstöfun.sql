--runs out of PGA memory
DECLARE
	ip varchar2(1000) := 'GNU is Not Unix';
	
	type collection_t is table of varchar2(1000);
	v_collection collection_t;

	space_pos pls_integer;
	start_pos pls_integer:=1;
	word varchar2(1000);
BEGIN
	loop
    space_pos := INSTR(ip, ' ', start_pos);
    if space_pos = 0 then
            word := substr(ip, start_pos);
    		v_collection.EXTEND;
    		v_collection(v_collection.LAST) := word;
		else
        word := SUBSTR(ip, start_pos, space_pos - start_pos);
        v_collection.EXTEND;
    		v_collection(v_collection.LAST) := word;
        start_pos := space_pos + 1;
    end if;
	end loop;

	for i in v_collection.FIRST..v_collection.LAST loop
        dbms_output.put_line(substr(v_collection(i),1,1));
	end loop;

END;
