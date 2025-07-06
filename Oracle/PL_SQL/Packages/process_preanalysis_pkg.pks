create or replace package process_preanalysis_pkg
as

    type range_parm_values_t is record(
    lower_bound process_ranges_parm.lower_bound%type,
    upper_bound process_ranges_parm.upper_bound%type
    );
    
    c_process_salaries constant process_ranges_parm.process_name%type := 'PROCESS SALARIES';
    
    function retrieve_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic;
    
    procedure print_bounds(p_parms in range_parm_values_t, low_or_high in boolean default true);
    
    procedure retrieve_range_values(p_process_name in process_ranges_parm.process_name%type, p_run_number in process_ranges_parm.run_number%type, p_parms out range_parm_values_t);

end process_preanalysis_pkg;
