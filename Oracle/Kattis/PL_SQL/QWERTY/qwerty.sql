DECLARE
    type lkp_t is table of varchar2(1) index by varchar2(1);
    d lkp_t := lkp_t (
    'a' => 'q',
    'b' => 'w',
    'c' => 'e',
    'd' => 'r',
    'e' => 't',
    'f' => 'y',
    'g' => 'u',
    'h' => 'i',
    'i' => 'o',
    'j' => 'p',
    'k' => 'a',
    'l' => 's',
    'm' => 'd',
    'n' => 'f',
    'o' => 'g',
    'p' => 'h',
    'q' => 'j',
    'r' => 'k',
    's' => 'l',
    't' => 'z',
    'u' => 'x',
    'v' => 'c',
    'w' => 'v',
    'x' => 'b',
    'y' => 'n',
    'z' => 'm',
    ' ' => ' ' 
    );

    subtype str_len is varchar2(1000);

    input str_len := 'epc aghvr xdiby niu qgzjl iwcd epc sktf mio';
    output str_len;

BEGIN
    for i in 1..length(input)
    loop
        output := output || d(substr(input, i, 1));
    end loop;

    dbms_output.put_line(output);

END;
/
