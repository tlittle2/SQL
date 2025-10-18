DECLARE
    ipString varchar2(32767) := 'Welcome_NWERC_participants!';

    type t_chars is table of char(1);
    type t_ans is table of pls_integer index by pls_integer;

    answers t_ans;

    ipLetters t_chars;

    upperLetters t_chars;
    lowerLetters t_chars;

    function populateStaticCollections(p_isUpper IN BOOLEAN DEFAULT TRUE)
    return t_chars
    is
        l_returnvalue t_chars := t_chars();
        l_upperA number := ascii('A');
        l_lowerA number := ascii('a');
        
        function calc_upper(p_ascii_number number)
        return number
        deterministic
        is begin
            return p_ascii_number + 25;
        end calc_upper;
    begin
        if p_isUpper
        then
            for i in l_upperA..calc_upper(l_upperA)
            loop
                l_returnvalue.EXTEND;
                l_returnvalue(i - l_upperA + 1):= chr(i);
            end loop;
        else
            for i in l_lowerA..calc_upper(l_lowerA)
            loop
                l_returnvalue.EXTEND;
                l_returnvalue(i - l_lowerA + 1):= chr(i);
            end loop;
        end if;
        
        return l_returnvalue;
    end populateStaticCollections;

    function populateIPTable(p_ipString IN VARCHAR2)
    return t_chars
    is
        l_returnvalue t_chars := t_chars();
    begin
        for i in 1..length(p_ipString)
        loop
            l_returnvalue.EXTEND;
            l_returnvalue(i) := substr(p_ipString, i, 1);
        end loop;
        
        return l_returnvalue;
    end populateIPTable;


    function isMember(p_chr IN CHAR, p_collection IN t_chars)
    return BOOLEAN
    is
        l_returnvalue boolean := false;
    begin
        if p_chr member of p_collection
        then
            return true;
        end if;

        return l_returnvalue;

    end isMember;

    function populateValues(p_letters in t_chars)
    return t_ans
    is  
        l_returnvalue t_ans := t_ans();
        lowerNumber PLS_INTEGER:= 0;
        upperNumber PLS_INTEGER:= 0;
        whiteNumber PLS_INTEGER:= 0;
        symbols PLS_INTEGER:= 0;
    begin
        for i in ipLetters.FIRST..ipLetters.LAST
        loop
            case
            when isMember(p_letters(i), upperLetters) then upperNumber:= upperNumber + 1;
            when isMember(p_letters(i), lowerLetters) then lowerNumber:= lowerNumber + 1;
            when isMember(p_letters(i), t_chars('_')) then whiteNumber:= whiteNumber + 1;
            else symbols:= symbols + 1;    
            end case;
        end loop;
        
        l_returnvalue(1) := whiteNumber;
        l_returnvalue(2) := lowerNumber;
        l_returnvalue(3) := upperNumber;
        l_returnvalue(4) := symbols;
    
        return l_returnvalue;

    end populateValues;

BEGIN

    upperLetters := populateStaticCollections(TRUE);
    lowerLetters := populateStaticCollections(FALSE);
    
    ipLetters := populateIPTable(ipString);
    
    answers := populateValues(ipLetters);

    for i in answers.first..answers.last
    loop
        dbms_output.put_line(round(answers(i) / length(ipString),15));

    end loop;

END;
/


select ascii('A'), ascii('Z') from dual;


select ascii('A'),ascii('A') + 25 from dual;
