create or replace PACKAGE BODY DATE_UTILS_PKG
AS

    FUNCTION GET_FORWARD_FLAG
    RETURN CHAR DETERMINISTIC
    IS 
    BEGIN
        RETURN c_forwards_direction;
    END;
    
    FUNCTION GET_BACKWARD_FLAG
    RETURN CHAR DETERMINISTIC
    IS
    BEGIN
        return c_backwards_direction;
    END;

	FUNCTION GET_YEAR_QUARTER(p_date IN DATE)
	RETURN VARCHAR2
	IS
		p_year NUMBER := EXTRACT(YEAR FROM p_date);
		p_quarter NUMBER := to_char(p_date, 'Q');
	BEGIN
		return FORMAT_YEAR_QUARTER(p_year, p_quarter);
	
    END GET_YEAR_QUARTER;


	FUNCTION FORMAT_YEAR_QUARTER(P_YEAR IN NUMBER, P_QUARTER IN NUMBER)
    RETURN VARCHAR2
	IS
	BEGIN
		return p_year || 'Q' ||  p_quarter;

	END FORMAT_YEAR_QUARTER;


	FUNCTION GET_QUARTER(p_month IN NUMBER)
	RETURN NUMBER
	IS
	BEGIN
        error_pkg.assert('NOT A VALID MONTH', p_month between 1 and 12);
		return CASE
			WHEN p_month in (1,2,3)    THEN 1
			WHEN p_month in (4,5,6)    THEN 2
			WHEN p_month in (7,8,9)    THEN 3
			WHEN p_month in (10,11,12) THEN 4
            end;
	END GET_QUARTER;
    

    
    
    FUNCTION GET_RANGE_OF_DATES(P_START_DATE IN DATE, P_NUM_OF_DAYS IN NUMBER, P_DIRECTION IN CHAR DEFAULT c_forwards_direction)
    RETURN DATE_TABLE_T PIPELINED
    IS
        date_table DATE_TABLE_T;
    BEGIN
        if p_direction = c_backwards_direction then
            for i in 0..P_NUM_OF_DAYS
            loop
                pipe row(P_START_DATE - i);
            end loop;
        else
            for i in 0..P_NUM_OF_DAYS
            loop
                pipe row(P_START_DATE + i);
            end loop;
            
        end if;
        return;
        
    END GET_RANGE_OF_DATES;
    
    
    FUNCTION GET_DATES_BETWEEN(P_START_DATE IN DATE, P_END_DATE IN DATE)
    RETURN DATE_TABLE_T PIPELINED
    IS
        date_table DATE_TABLE_T;
        v_days NUMBER := trunc(to_date(P_END_DATE) - to_date(P_START_DATE));
    BEGIN
        IF v_days >= 0 THEN
            FOR i IN 0 .. v_days
            LOOP
                PIPE ROW(P_START_DATE + i);
            END LOOP;
        END IF;
        
        RETURN;
        
    END GET_DATES_BETWEEN;
    
    FUNCTION GET_DATE_TABLE(p_calendar_string in varchar2,p_from_date in date := null,p_to_date in date := null)
    RETURN DATE_TABLE_T PIPELINED
    IS
        l_from_date                    date := coalesce(p_from_date, sysdate);
        l_to_date                      date := coalesce(p_to_date, add_months(l_from_date,12));
        l_date_after                   date;
        l_next_date                    date;
    BEGIN
        l_date_after := l_from_date - 1;
        loop
            dbms_scheduler.evaluate_calendar_string (
                calendar_string   => p_calendar_string,
                start_date        => l_from_date,
                return_date_after => l_date_after,
                next_run_date     => l_next_date
            );
            
            exit when l_next_date > l_to_date;
            
            pipe row (l_next_date);
            l_date_after := l_next_date;
        end loop;
        return;
    END;

END DATE_UTILS_PKG;
