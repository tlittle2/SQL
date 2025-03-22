CREATE TABLE ASTROLOGY(
      MONTH CHAR(3)
    , DAY_CUTOFF NUMBER(2,0)
    , EARLY_SIGN VARCHAR2(12)
    , LATE_SIGN VARCHAR2(12)
);



INSERT INTO ASTROLOGY VALUES('Mar',21, 'Pisces', 'Aries');
INSERT INTO ASTROLOGY VALUES('Apr',21, 'Aries', 'Taurus');
INSERT INTO ASTROLOGY VALUES('May',21, 'Taurus', 'Gemini');
INSERT INTO ASTROLOGY VALUES('Jun',22, 'Gemini', 'Cancer');
INSERT INTO ASTROLOGY VALUES('Jul',23, 'Cancer', 'Leo');
INSERT INTO ASTROLOGY VALUES('Aug',23, 'Leo', 'Virgo');
INSERT INTO ASTROLOGY VALUES('Sep',22, 'Virgo', 'Libra');
INSERT INTO ASTROLOGY VALUES('Oct',23, 'Libra', 'Scorpio');
INSERT INTO ASTROLOGY VALUES('Nov',23, 'Scorpio', 'Sagittarius');
INSERT INTO ASTROLOGY VALUES('Dec',22, 'Sagittarius', 'Capricorn');
INSERT INTO ASTROLOGY VALUES('Jan',21, 'Capricorn', 'Aquarius');
INSERT INTO ASTROLOGY VALUES('Feb',20, 'Aquarius', 'Pisces');

COMMIT;

DECLARE
ip varchar2(6)               := '5 May';
dy ASTROLOGY.DAY_CUTOFF%TYPE := to_number(substr(ip, 1, instr(ip, ' ')-1));
mth ASTROLOGY.MONTH%TYPE     := substr(ip, instr(ip, ' ') + 1, length(ip));

answer ASTROLOGY.EARLY_SIGN%TYPE;

BEGIN
    select 
        CASE 
               WHEN dy < a.DAY_CUTOFF THEN a.EARLY_SIGN 
               ELSE a.LATE_SIGN 
        END
        into answer
    FROM ASTROLOGY a
    WHERE a.MONTH = mth;

    dbms_output.put_line(answer);

END;
