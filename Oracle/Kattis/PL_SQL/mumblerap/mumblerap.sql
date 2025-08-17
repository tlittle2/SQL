DECLARE
    subtype max_varchar2 is varchar2(32767);
    ip_str max_varchar2 := 'yesterdayihad1001,BUTnowihave9999'; --user input
    
    type t_arr is table of number;
    arr t_arr := t_arr();

    procedure processInput(p_ipStr IN max_varchar2, p_arr IN OUT NOCOPY t_arr)
    is
        num_match max_varchar2;
    begin
        for i in 1..REGEXP_COUNT(p_ipStr, '\d+')
        loop
            num_match := REGEXP_SUBSTR(p_ipStr, '\d+', 1, i);
            if num_match is not null
            then
                p_arr.EXTEND;
                p_arr(arr.COUNT):= to_number(num_match);
            end if;
        end loop;
    end processInput;

    function findMax(p_arr IN t_arr)
    return integer
    is
        currMax integer:= -1;
    begin
        for i in arr.FIRST..arr.LAST
        loop
            currMax:= greatest(currMax, p_arr(i));
        end loop;

        return currMax;
    end;

BEGIN
    processInput(ip_str, arr);
    dbms_output.put_line(findMax(arr));
END;
