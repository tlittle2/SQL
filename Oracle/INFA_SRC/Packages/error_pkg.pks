create or replace package error_pkg
authid definer
as
    bulk_errors exception;
    pragma exception_init(bulk_errors, -24381);

    procedure log_error(p_app_info in varchar2);

    procedure print_error(p_app_info in varchar2);

    procedure assert(p_condition in boolean, p_error_message in varchar2);

end error_pkg;
