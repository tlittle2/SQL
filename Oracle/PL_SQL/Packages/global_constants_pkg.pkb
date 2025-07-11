create or replace package body global_constants_pkg
AS

    function get_regular_run_flag
    return char
    deterministic
    is
    begin
        return g_regular_run;
    end get_regular_run_flag;


    function get_special_run_flag
    return char
    deterministic
    is
    begin
        return g_special_run;
    end get_special_run_flag;

end global_constants_pkg;
