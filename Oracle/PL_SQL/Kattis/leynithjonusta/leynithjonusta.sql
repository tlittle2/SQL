DECLARE    
	ip varchar2(1000) :=  'keppnis forritun @ g mail . com';

BEGIN
	dbms_output.put_line(replace(ip, ' ' ,''));
END;
