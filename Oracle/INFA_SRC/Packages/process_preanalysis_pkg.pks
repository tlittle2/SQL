create or replace package process_preanalysis_pkg
as

    c_process_salaries constant process_ranges_parm.process_name%type := 'PROCESS SALARIES';
    c_contract_update constant process_ranges_parm.process_name%type := 'CONTRACT UPDATE';


    function get_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic;

    function get_constant_contract_update
    return process_ranges_parm.process_name%type
    deterministic;

    function generate_job_nbrs(p_current_value in process_ranges_parm.RUN_TOTAL%type, p_count_of_values in process_ranges_parm.RUN_TOTAL%type, p_job_runs in process_ranges_parm.RUN_TOTAL%type)
    return integer;

    function get_count_per_run(p_number_of_values in process_ranges_parm.RUN_TOTAL%type, p_job_runs in process_ranges_parm.RUN_TOTAL%type)
    return integer;

    procedure salary_processing_preanalysis(p_number_of_runs in process_ranges_parm.RUN_TOTAL%type);

    procedure update_contract_preanalysis(p_number_of_runs in process_ranges_parm.RUN_TOTAL%type);

    procedure check_for_overlap(p_process_name in process_ranges_parm.process_name%type);


    function archive_rules_jobNumber(p_rownum in number, p_num_of_runs in archive_rules.job_nbr%type)
    return archive_rules.job_nbr%type;

    procedure archive_preanalysis(p_number_of_runs in archive_rules.job_nbr%type);

    procedure purge_preanalysis(p_number_of_runs in archive_rules.job_nbr%type);

end process_preanalysis_pkg;
