DECLARE
    subtype charLength_ST is varchar2(1);
    type ipTable_t is table of pls_integer index by charLength_ST;
    ipTable ipTable_t;

    procedure processInput
    is
        ip varchar2(52):= 'AH 2H 3H 4H 5H';
        currChar charLength_ST;
    begin
        for i in 1..length(ip)
        loop
            if mod(i, 3) = 1 then
                currChar := substr(ip, i, 1);
                if ipTable.EXISTS(currChar) then
                    ipTable(currChar) := ipTable(currChar) + 1;
                else
                    ipTable(currChar) := 1;
                end if;
            end if;
        end loop;
    end;

    function produceAnswer
    return pls_integer
    is
        answer pls_integer := 0;
    begin
        for i in indices of ipTable
        loop
          if answer < ipTable(i) then
              answer := ipTable(i);
          end if;
        end loop;

        return answer;
    end;

BEGIN
    processInput;
    dbms_output.put_line(produceAnswer);
END;
