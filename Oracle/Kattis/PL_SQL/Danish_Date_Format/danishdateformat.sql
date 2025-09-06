set serveroutput on
declare
    ip varchar2(100) := '04/19/2024';

    subtype st_month_length is varchar2(20);
    type tbl is table of st_month_length index by pls_integer;

    l_month tbl := tbl(
    1  =>  'januar',
    2  =>  'februar',
    3  =>  'marts',
    4  =>  'april',
    5  =>  'maj',
    6  =>  'juni',
    7  =>  'juli',
    8  =>  'august',
    9  =>  'september',
    10 =>  'oktober',
    11 =>  'november',
    12 =>  'december'
    );
    
    sep char(1) := '/';

    m integer := to_number(substr(ip, 1, instr(ip, sep)-1));
    mName st_month_length := l_month(m);

    d integer := to_number(substr(ip, instr(ip, sep) + 1, 2));
    y integer := substr(ip, -4);
begin


   dbms_output.put_line(d || '. ' || mName || ' ' || y );

end;
/
