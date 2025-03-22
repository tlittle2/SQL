/*For practice with collections. In a normal scenario, the collection is an actual table and you query the table*/
DECLARE
    subtype aSign_ST is VARCHAR2(12);
    subtype monthString_ST is VARCHAR2(3);
    
    TYPE SIGN_T IS RECORD(
        dayCutoff NUMBER
        , earlySign aSign_ST
        , lateSign aSign_ST
    );
    
    TYPE CALENDAR_T IS TABLE OF SIGN_T INDEX BY monthString_ST;
    CALENDAR CONSTANT CALENDAR_T := CALENDAR_T(
        'Mar' => SIGN_T(21, 'Pisces', 'Aries'),
        'Apr' => SIGN_T(21, 'Aries', 'Taurus'),
        'May' => SIGN_T(21, 'Taurus', 'Gemini'),
        'Jun' => SIGN_T(22, 'Gemini', 'Cancer'),
        'Jul' => SIGN_T(23, 'Cancer', 'Leo'),
        'Aug' => SIGN_T(23, 'Leo', 'Virgo'),
        'Sep' => SIGN_T(22, 'Virgo', 'Libra'),
        'Oct' => SIGN_T(23, 'Libra', 'Scorpio'),
        'Nov' => SIGN_T(23, 'Scorpio', 'Sagittarius'),
        'Dec' => SIGN_T(22, 'Sagittarius', 'Capricorn'),
        'Jan' => SIGN_T(21, 'Capricorn', 'Aquarius'),
        'Feb' => SIGN_T(20, 'Aquarius', 'Pisces')
    );
    
    
    ip varchar2(6):= '30 Jul';
    dy NUMBER;
    mth monthString_ST;
    rw SIGN_T;


BEGIN
    dy := substr(ip, 1, instr(ip, ' '));
    mth := substr(ip, instr(ip, ' ') + 1, length(ip));
    rw:= CALENDAR(mth);

    if dy < rw.dayCutoff
    then
        dbms_output.put_line(rw.earlySign);
    else
        dbms_output.put_line(rw.lateSign);
    end if;

END;
/
