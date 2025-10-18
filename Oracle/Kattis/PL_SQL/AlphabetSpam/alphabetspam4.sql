DECLARE
    
    type t_chars is table of char(1);
    type t_ans is table of pls_integer index by pls_integer;
    
    function inc(p_val in pls_integer)
    return pls_integer
    is
    begin
        return p_val + 1;
    end inc;
    
    function calc_upper(p_ascii_number number)
    return number
    deterministic
    is
    begin
        return p_ascii_number + 25;
    end calc_upper;
    
    function populateStaticCollections(p_isUpper IN BOOLEAN DEFAULT TRUE)
    return t_chars
    is
        l_returnvalue t_chars := t_chars();
        l_upperA number := ascii('A');
        l_lowerA number := ascii('a');
    begin
        if p_isUpper
        then
            for i in l_upperA..calc_upper(l_upperA)
            loop
                l_returnvalue.EXTEND;
                l_returnvalue(inc(i - l_upperA)):= chr(i);
            end loop;
        else
            for i in l_lowerA..calc_upper(l_lowerA)
            loop
                l_returnvalue.EXTEND;
                l_returnvalue(inc(i - l_lowerA)):= chr(i);
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


    procedure alphabet_spam
    is  
        answers t_ans := t_ans();
        lowerNumber PLS_INTEGER:= 0;
        upperNumber PLS_INTEGER:= 0;
        whiteNumber PLS_INTEGER:= 0;
        symbols PLS_INTEGER:= 0;
        
        ipString varchar2(32767) := '\/\/in_US$100000_in_our_Ca$h_Lo||ery!!!';
        
        upperLetters t_chars := populateStaticCollections(TRUE);
        lowerLetters t_chars := populateStaticCollections(FALSE);
        ipLetters t_chars:= populateIPTable(ipString);
        
    begin
        for i in ipLetters.FIRST..ipLetters.LAST
        loop
            case
            when ipLetters(i) member of upperLetters then upperNumber:= inc(upperNumber);
            when ipLetters(i) member of lowerLetters then lowerNumber:= inc(lowerNumber);
            when ipLetters(i) member of t_chars('_') then whiteNumber:= inc(whiteNumber);
            else symbols:= inc(symbols);
            end case;
        end loop;
        
        answers(1) := whiteNumber;
        answers(2) := lowerNumber;
        answers(3) := upperNumber;
        answers(4) := symbols;
        
        for i in answers.first..answers.last
        loop
            dbms_output.put_line(round(answers(i) / length(ipString),15));
        end loop;

    end alphabet_spam;

BEGIN
    
    alphabet_spam;

END;
/
