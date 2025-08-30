create or replace package debug_pkg
authid definer
as
    procedure debug_off;
    procedure debug_on;

    function get_debug_state return boolean;

    function get_debug_state_str return varchar2;

    procedure start_timer(p_context in varchar2 := null);

    function show_elapsed_time
    return number;

    procedure print(p_value in varchar2);

end debug_pkg;
