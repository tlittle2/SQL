DECLARE
    type char_arr_t is table of varchar(1);
    c_arr char_arr_t:= char_arr_t();
    ip_arr char_arr_t:= char_arr_t();
    missing varchar(26);

    ip varchar2(100) := 'The quick brown fox jumps over the lazy dog.'; --input

BEGIN
    
    for i in ascii('a')..ascii('z')--get set of all lower case letters(ascii 97-122)
    loop
        c_arr.EXTEND;
        c_arr(i - ascii('a') + 1):= chr(i); --indices 1-26
    end loop;

    
    for i in 1..length(ip)--add all characters from input to nested table
    loop
        if lower(substr(ip, i, 1)) member of c_arr
        then
            ip_arr.EXTEND;
            ip_arr(ip_arr.LAST):= lower(substr(ip, i, 1));
        end if;
    end loop;

    for i in 1..c_arr.COUNT --see what letters are missing
    loop
        if c_arr(i) not member of ip_arr
        then
            missing:= missing || c_arr(i);
        end if;
    end loop;

    --return if it's a panagram or not
    if length(missing) is null
    then
        dbms_output.put_line('pangram');    
    else
        dbms_output.put_line('missing ' || missing);
    end if;
    
END;
