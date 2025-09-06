DECLARE
  ip varchar2(1000) := 'art';
  ans varchar2(1000) := substr(ip, instr(ip, 'a'), length(ip));
      
BEGIN
    dbms_output.put_line(ans);
    
END;
/
