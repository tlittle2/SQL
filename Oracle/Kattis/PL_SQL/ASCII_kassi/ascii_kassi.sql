declare
    n integer := 3;

    function printBorder
    return varchar2
    is
        plus constant char(1) := '+';
    begin
        return plus || rpad('-', n, '-') || plus;
    end printBorder;

    function printSides
    return varchar2
    is
        pipe constant char(1) := '|';
    begin
        return pipe || rpad(' ', n, ' ') || pipe;

    end printSides;

begin
    dbms_output.put_line(printBorder);

    for i in 1..n
    loop
        dbms_output.put_line(printSides);
    end loop;

    dbms_output.put_line(printBorder);
end;
/
