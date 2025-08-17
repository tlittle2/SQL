DECLARE    
    type t_arr is table of integer;
    arr t_arr := t_arr();

    ip integer := 25; --user input

    procedure addValue(a in out t_arr, val integer)
    is
    begin
        a.EXTEND;
        a(a.LAST):= val;
    end addValue;

    procedure calculateOutput
    is
    begin
        loop
            exit when ip <= 5;
            addValue(arr, 3);
            ip:= ip-3;
        end loop;
        
        if ip = 5
        then
            addValue(arr, 3);
            addValue(arr, 2);
        elsif ip=4
        then
            addValue(arr, 2);
            addValue(arr, 2);
        elsif ip=3
        then
            addValue(arr, 3);
        elsif ip=2
        then
            addValue(arr, 2);
        end if;
    end calculateOutput;

    procedure displayOutput
    is
    begin
        dbms_output.put_line(arr.COUNT);
        dbms_output.put_line(lpad('-', length(arr.COUNT) *4, '-'));
        for i in arr.FIRST..arr.LAST
        LOOP
            dbms_output.put_line(arr(i));
        END LOOP;
    end displayOutput;
        

BEGIN
      calculateOutput;
    displayOutput;
END;
