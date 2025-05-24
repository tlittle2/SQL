DECLARE
    subtype ansLength is VARCHAR2(100);
    ipStr ansLength := 'PpIiKkAaCcHhUu';
    encodedStr VARCHAR2(1000):= '001004006008010012014';
    
    type t_idxTable IS TABLE OF NUMBER;
    idxTable t_idxTable := t_idxTable();

    ans ansLength := '';

    procedure convertEncoded(p_encodeStr IN VARCHAR2, p_idxTable IN OUT NOCOPY t_idxTable)
    is
    windowIdx NUMBER(1,0):= 3;
    BEGIN
        for i in 1..length(p_encodeStr)
        loop
            if mod(i, windowIdx) = 0
            then
                p_idxTable.EXTEND;
                p_idxTable(p_idxTable.LAST) := cast(substr(p_encodeStr, i-(windowIdx-1), windowIdx) AS NUMBER);
            end if;
        end loop;
    END;

    procedure calcAns(p_ipStr IN ansLength, p_idxTable IN t_idxTable, p_ans OUT ansLength)
    is
    begin
        for i in p_idxTable.FIRST .. p_idxTable.LAST
        loop
            p_ans:= p_ans || substr(p_ipStr, p_idxTable(i), 1);
        end loop;

    end;

BEGIN
    convertEncoded(encodedStr, idxTable);
    calcAns(ipStr, idxTable, ans);

    dbms_output.put_line(ans);

END;
