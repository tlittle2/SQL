CREATE OR REPLACE PACKAGE PKG_SF_TIMER AS
    FUNCTION elapsed_time RETURN NUMBER;
	PROCEDURE start_timer (context_in IN VARCHAR2:=NULL);

END PKG_SF_TIMER;

CREATE OR REPLACE PACKAGE BODY PKG_SF_TIMER AS
    /* package variable which stores the last timing made */
    last_timing NUMBER:= NULL;

	/* package variable which stores the last time context made */
	last_context VARCHAR2 (32767) := NULL;

	/* private variable for storing "factor" */
	v_factor NUMBER := NULL;

    /*private variable for toggling on and off*/
	v_onoff BOOLEAN := TRUE;

	/* private variable for repeats */
	v_repeats NUMBER := 100;

    /* Calibrate base timing */
	v_base_timing NUMBER:= NULL;

	/* get the elapsed time (intended to run after running the start_timer Procedure )*/
    FUNCTION elapsed_time
            RETURN NUMBER
        IS
            l_end_time PLS_INTEGER := DBMS_UTILITY.get_time;
    	BEGIN
            if v_onoff
            then
            	RETURN MOD(l_end_time - last_timing + POWER(2, 32), POWER(2,32));
    
    		end if;
	
	END;

	PROCEDURE start_timer (context_in IN VARCHAR2 := NULL) is
        BEGIN
        	last_timing := DBMS_UTILITY.get_time;
			last_context := context_in;

        END;
        
END PKG_SF_TIMER;
