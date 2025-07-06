DECLARE
    type t_chars is table of char(1);
    vowels t_chars := t_chars('a','e','i','o', 'u');
    ipString varchar2(20) := 'andrex naxos';
    
    kid varchar2(10):= substr(ipString, 1, instr(ipString, ' ')-1);
    parent varchar2(10):= substr(ipString, instr(ipString, ' ')+1, length(ipString));

    outString varchar2(20);
    
BEGIN
    dbms_output.put_line(kid);
    dbms_output.put_line(parent);
    case
        when substr(kid, length(kid),1) = 'e' then outString := kid || 'x' || parent;
        when substr(kid, length(kid)-1,2) = 'ex' then outString := kid || parent;
        when substr(kid, length(kid),1) member of vowels then outString:= substr(kid, 1,length(kid)- 1) || 'ex' || parent;
        else outString := kid || 'ex' || parent;
    end case;

    dbms_output.put_line(outString);
END;
