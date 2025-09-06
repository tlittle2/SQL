DECLARE
    subtype holiday_st is varchar2(10);
    type holidays_t is table of pls_integer index by holiday_st;

    holidays holidays_t := holidays_t(
        'OCT 31' => 1,
        'DEC 25' => 2
    );

    ip holiday_st := 'OCT 31';

BEGIN
    if holidays.exists(ip)
    then
        dbms_output.put_line('yep');
    else
        dbms_output.put_line('nope');
    end if;
    
END;
/
