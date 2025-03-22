DECLARE
	ip varchar2(100) := 'PieHard 3.14159265358979323846';

	ip_title VARCHAR2(100) := SUBSTR(ip, 1, INSTR(ip, ' ') - 1);
  	ip_cost FLOAT(10) := CAST(TRIM(SUBSTR(ip, INSTR(ip, ' ') + 1)) AS FLOAT);

  	title_length INTEGER := LENGTH(ip_title);	
BEGIN
	IF ip_cost < title_length
	THEN
        	DBMS_OUTPUT.PUT_LINE(ip_cost);
    	ELSE
        	DBMS_OUTPUT.PUT_LINE(title_length);
    	END IF;
END;
