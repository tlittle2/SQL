create or replace package body error_pkg
as
    e_stop exception;

    procedure run_rollback(p_rollback in boolean)
    is
    begin
        if p_rollback
        then
            rollback;
        end if;
    end run_rollback;

    procedure run_stop(p_stop in boolean)
    is
    begin
        if p_stop
        then
            raise e_stop;
        end if;
    end run_stop;

    procedure print_error_log(p_app_info in varchar2, p_stop in boolean)
    is
    begin
        dbms_output.put_line('ERROR IN: ' || p_app_info);
        dbms_output.put_line(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        dbms_output.put_line(DBMS_UTILITY.FORMAT_ERROR_STACK);
    exception
        when others then
        raise;
    end print_error_log;

    procedure ins_error_log(p_app_info in error_log.ERROR_INFO%type, p_sql_code in integer)
    is
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
            , p_sql_code
            , DBMS_UTILITY.FORMAT_CALL_STACK
            , DBMS_UTILITY.FORMAT_ERROR_STACK
            , DBMS_UTILITY.FORMAT_ERROR_BACKTRACE
            , p_app_info
        );
    exception
        when others then
        print_error_log('ins_error_log', true);
    end ins_error_log;


    procedure record_error(p_app_info in varchar2, p_stop in boolean) --this can be, for example, the procedure that called this
    is
        PRAGMA AUTONOMOUS_TRANSACTION; --ensures that we don't commit changes in callback program
    begin
        ins_error_log(p_app_info, SQLCODE);
        COMMIT;
    exception
        when others then
        print_error_log('record_error', false);
    end record_error;

    procedure log_error(p_print in boolean, p_stop in boolean, p_app_info in varchar2)
    is
    begin
        if p_print
        then
            print_error_log(p_app_info, p_stop);
        else
            record_error(p_app_info, p_stop);
        end if;
    exception
        when others then
        raise;
    end log_error;


    procedure run_error_log(p_app_info in varchar2, p_print in boolean default false, p_rollback in boolean default false, p_stop in boolean)
    is
    begin
        run_rollback(p_rollback);
        log_error(p_print, p_stop, p_app_info);
        run_stop(p_stop);
        debug_pkg.debug_off;
    exception
        when others then
        raise;
    end run_error_log;


    procedure run_error_log(p_cursor in out sql_utils_pkg.ref_cursor_t, p_app_info in varchar2, p_print in boolean default false, p_rollback in boolean default false, p_stop in boolean)
    is
    begin
        sql_utils_pkg.close_cursor(p_cursor);
        run_error_log(p_app_info, p_print, p_rollback, p_stop);
    exception
        when others then
        raise;
    end run_error_log;

end error_pkg;
