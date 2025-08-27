create or replace package process_preanalysis_pkg
as

    c_process_salaries constant process_ranges_parm.process_name%type := 'PROCESS SALARIES';

    function get_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic;

    procedure archive_rules_preanalysis(p_number_of_runs in number, p_partitioned_flag in partition_table_parm.partitioned%type);

end process_preanalysis_pkg;
