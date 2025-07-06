DECLARE
    type t_arr is table of varchar2(12);
    problems t_arr := t_arr('2+2','1+2','P=NP','0+0');    --user input

    FUNCTION solveProblem(ip VARCHAR2)
    return INTEGER
    is
        delimiter CHAR(1):= '+';
        num1 integer := to_number(substr(ip, 0, instr(ip,delimiter)-1));
        num2 integer := to_number(substr(ip, instr(ip,delimiter), length(ip)));
    BEGIN
        return num1+num2;
    END;

    FUNCTION evaluateProblem(ip VARCHAR2)
    RETURN BOOLEAN
    IS
        badIP CONSTANT VARCHAR2(4):= 'P=NP';
    BEGIN
        if ip = badIP then
            return True;
        else
            return False;
        end if;
    END;

BEGIN
    for i in problems.FIRST..problems.LAST
    LOOP
        if evaluateProblem(problems(i))
        then
            dbms_output.put_line('SKIPPED');
        else
            dbms_output.put_line(solveProblem(problems(i)));
        end if;
    END LOOP;
END;
