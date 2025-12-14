create or replace package process_preanalysis_pkg
as

    c_process_salaries constant process_ranges_parm.process_name%type := 'PROCESS SALARIES';


    function get_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic;

    function generate_job_nbrs(p_current_value in process_ranges_parm.RUN_TOTAL%type, p_count_of_values in process_ranges_parm.RUN_TOTAL%type, p_job_runs in process_ranges_parm.RUN_TOTAL%type)
    return integer;

    function get_count_per_run(p_number_of_values in process_ranges_parm.RUN_TOTAL%type, p_job_runs in process_ranges_parm.RUN_TOTAL%type)
    return integer;

    procedure archive_rules_preanalysis(p_number_of_runs archive_rules.job_nbr%type, p_partitioned_flag in partition_table_parm.partitioned%type);

    procedure salary_processing_preanalysis(p_number_of_runs in process_ranges_parm.RUN_TOTAL%type);

    procedure check_for_overlap(p_process_name process_ranges_parm.process_name%type);


end process_preanalysis_pkg;
