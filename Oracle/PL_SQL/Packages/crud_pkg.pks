create or replace PACKAGE crud_pkg
AS
/*meant to be a better replacement to the table_access_pkg -> you also may, depending on the application, may disperse these accessor methods into different distinct packages rather than all of these in 1 package*/

    function get_infa_global_row
    return infa_global%rowtype;

	function get_global_fix_row
    return infa_global%rowtype;

	function get_global_row_logic(p_run_type in char default global_constants_pkg.g_regular_run)
    return infa_global%rowtype;

	procedure update_global_row_logic(p_row in infa_global%rowtype, p_run_type in char default global_constants_pkg.g_regular_run);

    function get_process_ranges_parm_row(p_process_name in process_ranges_parm.process_name%type
                                       , p_run_number in process_ranges_parm.run_number%type)
    return process_ranges_parm%rowtype;

    function get_salary_data_stg1(p_case_num in salary_data_stg.case_num%type)
    return salary_data_stg%rowtype;

    procedure remove_salary_data_stg1(p_case_num in salary_data_stg.case_num%type);

    procedure update_partition_table_parm(p_row in partition_table_parm%rowtype);

    procedure update_partition_table_parm(p_table_owner in partition_table_parm.table_owner%TYPE,
                                          p_table_name  in partition_table_parm.table_name%TYPE,
                                          p_row in partition_table_parm%rowtype);

    procedure update_safe_partition_table_parm(p_table_owner in partition_table_parm.table_owner%TYPE,
                                               p_table_name in partition_table_parm.table_name%TYPE,
                                               p_row in partition_table_parm%rowtype);                                        
    procedure reset_partition_parm;

end crud_pkg;
