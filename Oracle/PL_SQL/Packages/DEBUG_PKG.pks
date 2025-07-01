create or replace PACKAGE DEBUG_PKG
AUTHID DEFINER
AS
    procedure debug_off;
    procedure debug_on;
    
    function get_debug_state return boolean;
    
    --Return string equivalent of boolean
    function return_debug_state return varchar2;
    
    PROCEDURE START_TIMER(p_context IN VARCHAR2 := NULL);
	
	FUNCTION SHOW_ELAPSED_TIME
	RETURN NUMBER;
    
    PROCEDURE print(p_value IN VARCHAR2);
    
END DEBUG_PKG;
