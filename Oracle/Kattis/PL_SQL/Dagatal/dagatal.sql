DECLARE
   ip integer;
   type map_t is table of integer index by pls_integer;
   map map_t := map_t(
        1=> 31,
        2=> 28,
        3=> 31,
        4=> 30,
        5=> 31,
        6=> 30,
        7=> 31,
        8=> 31,
        9=> 30,
        10=> 31,
        11=> 30,
        12=> 31
   );

BEGIN
    ip := :x;
    dbms_output.put_line(map(ip));
END;
/
