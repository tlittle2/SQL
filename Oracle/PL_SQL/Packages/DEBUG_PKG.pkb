create or replace PACKAGE BODY DEBUG_PKG
AS
    c_debugging boolean := false;
    
    last_timing NUMBER := NULL;
	last_context STRING_UTILS_PKG.st_max_pl_varchar2;
	
	v_onoff BOOLEAN := TRUE;

    procedure debug_on
    is
    begin
        c_debugging := true;
    end debug_on;
    
    procedure debug_off
    is
    begin
        c_debugging := false;
    end debug_off;
    
    function get_debug_state
    return boolean
    is
    begin
        return c_debugging;
    end get_debug_state;
    
    
    function return_debug_state
    return varchar2
    is
    begin
        return string_utils_pkg.bool_to_str(DEBUG_PKG.get_debug_state);
    end;
    
	
	PROCEDURE START_TIMER(p_context IN VARCHAR2 := NULL)
	IS
	BEGIN
		last_timing := dbms_utility.get_time;
		last_context := p_context;
	END START_TIMER;
	
	
	FUNCTION SHOW_ELAPSED_TIME
	RETURN NUMBER
	IS
		l_end_time PLS_INTEGER := dbms_utility.get_time;
	BEGIN
		ERROR_PKG.ASSERT('No time to compare against!', last_timing is not null);
		
		RETURN MOD(l_end_time - last_timing + POWER(2, 32), POWER(2, 32));
		
	END SHOW_ELAPSED_TIME;

END DEBUG_PKG;
