CREATE TABLE KARTE(
    SUIT CHAR(1),
    CARD_NUM NUMBER(2,0)
);

CREATE TABLE KARTE_DIM(
    SUIT CHAR(1)
);

INSERT INTO KARTE_DIM VALUES('P');
INSERT INTO KARTE_DIM VALUES('K');
INSERT INTO KARTE_DIM VALUES('H');
INSERT INTO KARTE_DIM VALUES('T');

COMMIT;

--=========================================================================================================

DECLARE
    ip varchar2(1000) := 'H02H10P11H02'; --user input
    subtype st_ansLength is varchar2(6);

    procedure processInput(p_ipString IN VARCHAR2)
    is
        v_Idx number := 1;
            const_sublength constant number :=3;
            v_word varchar2(3);
            v_key KARTE.SUIT%TYPE;
            v_value varchar2(2);
    begin
        EXECUTE IMMEDIATE 'TRUNCATE TABLE KARTE';
        
        loop
            if v_Idx > length(p_ipString)
            then
                exit;
            end if;
            
            v_word := substr(p_ipString, v_Idx, const_sublength);
            v_key := substr(v_word, 1,1);
            v_value := to_number(substr(v_word, 2,2));
            INSERT INTO KARTE VALUES(v_key, v_value);
                
            v_Idx:= v_Idx + const_sublength;
        end loop;
            
        commit;
    end processInput;

    function isGreska
    return boolean
    is
            isGreska NUMBER;
    begin
            select count(1)
            into isGreska
            from (
                select dim.suit
            , count(nvl(k.card_num,0)) as cnt
            , count(distinct nvl(k.card_num,0)) as cnt_distinct
            from karte_dim dim
            left outer join karte k
            on dim.suit = k.suit
            group by dim.suit
            ) where cnt_distinct < cnt;

            if isGreska > 0
            then
                return True;
            end if;
    
            return False;
    end isGreska;
    
    procedure displayOutput
    is
        cursor cur_createOutput is
        select LISTAGG(cardsLeft, ' ') WITHIN GROUP (ORDER BY rownum) as answer from (
            select suit, 13-cnt as cardsLeft from (
                select dim.suit
                ,count(distinct k.card_num) as cnt
                from karte_dim dim
                left outer join karte k
                on dim.suit = k.suit
                group by dim.suit
            )
        );
    begin
        for rec in cur_createOutput
        loop
            dbms_output.put_line(rec.answer);
        end loop;
    end displayOutput;

BEGIN
    processInput(ip);
    
    if isGreska
    THEN
        dbms_output.put_line('GRESKA');
    else
        displayOutput;
    end if;
END;
