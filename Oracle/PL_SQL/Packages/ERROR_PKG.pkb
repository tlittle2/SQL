create or replace PACKAGE BODY ERROR_PKG
AS
	procedure assert (p_error_message in varchar2, p_condition in boolean)
    is
        begin
        if not nvl(p_condition, false) then
            DEBUG_PKG.debug_off;
            raise_application_error (-20000, p_error_message);
        end if;
    end;
    
    
    PROCEDURE PRINT_ERROR(p_app_info IN VARCHAR2)
    IS
    BEGIN
        dbms_output.put_line('ERROR IN' || p_app_info);
        dbms_output.put_line(SQLCODE || ':' || SQLERRM);
    END;
    
    
    PROCEDURE LOG_ERROR(p_app_info IN VARCHAR2) --this can be, for example, the procedure that called this 
    IS
        PRAGMA AUTONOMOUS_TRANSACTION; --ensures that we don't commit changes in callback program
        c_code CONSTANT INTEGER := SQLCODE;
    BEGIN
        INSERT INTO ERROR_LOG(
          CREATE_TS
        , CREATED_BY
        , ERROR_CODE
        , CALL_STACK
        , ERROR_STACK
        , BACKTRACE
        , ERROR_INFO
        )
        VALUES(
            systimestamp
            , USER
            , c_code
            , DBMS_UTILITY.FORMAT_CALL_STACK
            , DBMS_UTILITY.FORMAT_ERROR_STACK
            , DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            , p_app_info
        );
        COMMIT;
    END;

END ERROR_PKG;
