create or replace package body debug_pkg
as
    debug_state boolean := false;
    
    last_timing number := null;
    last_context string_utils_pkg.st_max_pl_varchar2;
    
    v_onoff boolean := true;

    procedure debug_on
    is
    begin
        debug_state := true;
    end debug_on;
    
    procedure debug_off
    is
    begin
        debug_state := false;
    end debug_off;
    
    function get_debug_state
    return boolean
    is
    begin
        return debug_state;
    end get_debug_state;
    
    
    function return_debug_state
    return varchar2
    is
    begin
        return string_utils_pkg.bool_to_str(debug_pkg.get_debug_state);
    end return_debug_state;
    
    procedure print(p_value in varchar2)
    is
    begin
        if debug_pkg.get_debug_state
        then
            dbms_output.put_line(p_value);
        end if;
    end print;
    
    
    procedure start_timer(p_context in varchar2 := null)
    is
    begin
        last_timing := dbms_utility.get_time;
        last_context := p_context;
    end start_timer;
    
    
    function show_elapsed_time
    return number
    is
        l_end_time pls_integer := dbms_utility.get_time;
    begin
        error_pkg.assert(last_timing is not null, 'No time to compare against!');
        
        return mod(l_end_time - last_timing + power(2, 32), power(2, 32));
        
    end show_elapsed_time;

end debug_pkg;
