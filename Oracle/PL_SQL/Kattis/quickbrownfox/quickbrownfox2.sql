DECLARE
    type char_arr_t is table of char(1);
    c_arr char_arr_t:= char_arr_t();
    ip_arr char_arr_t:= char_arr_t();
    missing varchar(26);

    ip varchar2(100) := 'ZYXW, vu TSR Ponm lkj ihgfd CBA.';

    procedure getSetOfCharacters(p_chrset IN OUT char_arr_t)
    is
    begin
        for i in ascii('a')..ascii('z')
        loop --97-122
            p_chrset.EXTEND;
            p_chrset(i - ascii('a') + 1):= chr(i); --indices 1-26
        end loop;
    end getSetOfCharacters;

    procedure getCharactersfromInput(p_ipString IN VARCHAR2, p_c_arr IN char_arr_t, p_ip_arr IN OUT char_arr_t)
    is 
    begin
        for i in 1..length(p_ipString)
        loop
            if lower(substr(p_ipString, i, 1)) member of p_c_arr
            then
                p_ip_arr.EXTEND;
                p_ip_arr(p_ip_arr.LAST):= lower(substr(p_ipString, i, 1));
            end if;
        end loop;
    end getCharactersfromInput;

    procedure computeMissing(p_c_arr IN char_arr_t, p_ip_arr IN char_arr_t, p_outString IN OUT VARCHAR2)
    IS
    BEGIN
        for i in 1..p_c_arr.COUNT
        loop
            if p_c_arr(i) not member of p_ip_arr
            then
                p_outString:= p_outString || p_c_arr(i);
            end if;
        end loop;
    END computeMissing;

    function isPanagram(p_ip_string VARCHAR2)
    RETURN VARCHAR2
    IS
    BEGIN
        if length(p_ip_string) is null
        then
            RETURN 'pangram';
        else
            RETURN 'missing ' || missing;
        end if;
    END isPanagram;


BEGIN
    getSetOfCharacters(c_arr);
    getCharactersfromInput(ip,c_arr,ip_arr);
    computeMissing(c_arr,ip_arr, missing);
    dbms_output.put_line(isPanagram(missing));
END;
