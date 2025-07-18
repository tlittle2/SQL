DECLARE
    ipString varchar2(32767) := '\/\/in_US$100000_in_our_Ca$h_Lo||ery!!!';

    type t_chars is table of char(1);

    ipLetters t_chars := t_chars();

    upperLetters t_chars := t_chars();
    lowerLetters t_chars := t_chars();

    lowerNumber PLS_INTEGER:= 0;
    upperNumber PLS_INTEGER:= 0;
    whiteSpacesNumber PLS_INTEGER:= 0;
    symbols PLS_INTEGER:= 0;

    
    function calculation(p_num IN PLS_INTEGER, p_ipString IN varchar2)
    return FLOAT
    is
    begin
        return p_num / length(p_ipString);
    end calculation;

    procedure populateStaticCollections(p_letters IN OUT t_chars, p_isUpper IN BOOLEAN DEFAULT TRUE)
    is 
    begin
        if p_isUpper
        then
            for i in ascii('A')..ascii('Z')
            loop
                p_letters.EXTEND;
                p_letters(i - ascii('A') + 1):= chr(i);
            end loop;
        else
            for i in ascii('a')..ascii('z')
            loop
                p_letters.EXTEND;
                p_letters(i - ascii('a') + 1):= chr(i);
            end loop;
        end if;
    end populateStaticCollections;

    procedure populateIPTable(p_ipString IN VARCHAR2, p_ipLetters IN OUT t_chars)
    is
    begin
        for i in 1..length(p_ipString)
        loop
            p_ipLetters.EXTEND;
            p_ipLetters(i) := substr(p_ipString, i, 1);
        end loop;

    end populateIPTable;
    
    function isMember(p_chr IN CHAR, p_collection IN t_chars)
    return BOOLEAN
    is
    begin
        if p_chr member of p_collection then
        return true;
        end if;
        
        return false;
    end isMember;

    procedure printAnswer(p_ipNumber IN PLS_INTEGER, p_ipString VARCHAR2) is
    begin
        dbms_output.put_line(round(calculation(p_ipNumber, p_ipString),15));
    end printAnswer;

BEGIN
    populateStaticCollections(upperLetters, TRUE);
    populateStaticCollections(lowerLetters, FALSE);
    populateIPTable(ipString,ipLetters);
    
    for i in ipLetters.FIRST..ipLetters.LAST
    loop        
        case
            when isMember(ipLetters(i), upperLetters) then upperNumber:= upperNumber + 1;
            when isMember(ipLetters(i), lowerLetters) then lowerNumber:= lowerNumber + 1;
            when isMember(ipLetters(i), t_chars('_')) then whiteSpacesNumber:= whiteSpacesNumber + 1;
            else symbols:= symbols + 1;
        end case;
    end loop;

    printAnswer(whiteSpacesNumber, ipString);
    printAnswer(lowerNumber, ipString);
    printAnswer(upperNumber, ipString);
    printAnswer(symbols, ipString);
    
END;
