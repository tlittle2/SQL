DECLARE
    TYPE t_vowels is table of char(1);
    vowels t_vowels := t_vowels('a','e', 'i','o','u','y');

    ip varchar2(1000) := 'brrrrrrrrrrrrrrrrrrrrrrrrrrrrrrra';

BEGIN
    if substr(ip, 1,1) = 'b' and (substr(ip, 2,1) = 'r'
        and REGEXP_COUNT(ip, 'r')> 1)
        and (substr(ip, length(ip), 1) member of vowels and substr(ip, length(ip)-1, 1) not member of vowels)
    then
        dbms_output.put_line('Jebb');
    else
            dbms_output.put_line('Neibb');
    end if;
END;
