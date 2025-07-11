create or replace package global_constants_pkg
AS
    g_regular_run CONSTANT CHAR(1) := 'R';
    g_special_run CONSTANT CHAR(1) := 'S';

    function get_regular_run_flag
    return char
    deterministic;


    function get_special_run_flag
    return char
    deterministic;

end global_constants_pkg;
