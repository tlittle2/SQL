create or replace package body process_preanalysis_pkg
as

    function retrieve_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic
    is
    begin
        return c_process_salaries;
    end retrieve_constant_process_salary;
    
    procedure print_bounds(p_parms in range_parm_values_t, low_or_high in boolean default true)
    is
        bound_type process_ranges_parm.process_name%type;
        bound_to_print process_ranges_parm.lower_bound%type;
    begin
        if low_or_high
        then
            bound_type := 'lower';
            bound_to_print := p_parms.lower_bound;
            
        else
            bound_type := 'upper';
            bound_to_print := p_parms.upper_bound;
            
        end if;
        
        dbms_output.put_line(bound_type || ' bound: ' || bound_to_print);
    
    end print_bounds;
    
    
    procedure retrieve_range_values(p_process_name in process_ranges_parm.process_name%type, p_run_number in process_ranges_parm.run_number%type, p_parms out range_parm_values_t)
    is
    begin
        error_pkg.assert(p_process_name in (c_process_salaries), 'CONSTANT NOT RECOGNIZED! PLEASE INVESTIGATE!');

    	select lower_bound, upper_bound
    	into p_parms.lower_bound, p_parms.upper_bound
    	from process_ranges_parm
    	where process_name = p_process_name
    	and run_number = p_run_number;
        
        dbms_output.put_line('lower bound: ' || p_parms.lower_bound);
        dbms_output.put_line('upper bound: ' || p_parms.upper_bound);
        
        error_pkg.assert(p_parms.lower_bound is not null or p_parms.upper_bound is not null, 'NO RANGE FOUND FOR PARAMETERS PROVIDED! PLEASE INVESTIGATE!');

    end retrieve_range_values;
    
end process_preanalysis_pkg;
