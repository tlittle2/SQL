DECLARE
    subtype ansLength is VARCHAR2(100);
    str ansLength := 'PpIiKkAaCcHhUu';
    encodedStr VARCHAR2(1000):= '001004006008010012014';
    windowIdx NUMBER(1,0):=3;

    type t_idxTable IS TABLE OF NUMBER;
    idxTable t_idxTable := t_idxTable();

    ans ansLength := '';

BEGIN
    for i in 1..length(encodedStr)
    loop
        if mod(i, windowIdx) = 0
        then
            idxTable.EXTEND;
            idxTable(idxTable.LAST) := cast(substr(encodedStr, i-(windowIdx-1), windowIdx) AS NUMBER);
        end if;
    end loop;

    for i in idxTable.FIRST .. idxTable.LAST
    loop
        ans:= ans || substr(str, idxTable(i), 1);
    end loop;

    dbms_output.put_line(ans);

END;
