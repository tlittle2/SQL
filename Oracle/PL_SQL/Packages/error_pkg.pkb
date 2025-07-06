create or replace package body error_pkg
as
    procedure assert (p_condition in boolean, p_error_message in varchar2)
    is
    begin
        if not nvl(p_condition, false) then
            debug_pkg.debug_off;
            raise_application_error (-20000, p_error_message);
        end if;
    end;
    
    
    procedure print_error(p_app_info in varchar2)
    is
    begin
        dbms_output.put_line('ERROR IN' || p_app_info);
        dbms_output.put_line(SQLCODE || ':' || SQLERRM);
    END;
    
    
    procedure log_error(p_app_info in varchar2) --this can be, for example, the procedure that called this 
    is
        PRAGMA AUTONOMOUS_TRANSACTION; --ensures that we don't commit changes in callback program
        c_code CONSTANT INTEGER := SQLCODE;
    begin
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
    end;

end error_pkg;
