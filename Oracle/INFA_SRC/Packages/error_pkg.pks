icreate or replace package error_pkg
authid definer
as
    bulk_errors exception;
    pragma exception_init(bulk_errors, -24381);
    
    procedure run_error_log(p_app_info in varchar2, p_print in boolean default false, p_rollback in boolean default false, p_stop in boolean);
    procedure run_error_log(p_cursor in out sql_utils_pkg.ref_cursor_t, p_app_info in varchar2, p_print in boolean default false, p_rollback in boolean default false, p_stop in boolean);
    
/*Explanation of default behaviors
rollback should be false by default. Developer shall decide if they want to rollback
printing the error to stdout should be false by default. recording to error_log table shall be default behavior
stopping shall have no default behavior. Developer shall explicitly state this functionality when invoking the procedure
*/
	
end error_pkg;
