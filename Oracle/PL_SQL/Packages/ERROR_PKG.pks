create or replace PACKAGE ERROR_PKG
AUTHID DEFINER
AS
    BULK_ERRORS EXCEPTION;
    PRAGMA EXCEPTION_INIT(BULK_ERRORS, -24381);
    
    PROCEDURE LOG_ERROR(p_app_info IN VARCHAR2);
    
    PROCEDURE PRINT_ERROR(p_app_info IN VARCHAR2);
	
    PROCEDURE assert(p_error_message in varchar2, p_condition in boolean);
END;
