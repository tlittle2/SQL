create or replace PACKAGE crud_pkg
AS

    function get_infa_global_row
    return infa_global%rowtype;

	function get_global_fix_row
    return infa_global%rowtype;

	function get_global_row_logic(p_run_type IN CHAR := global_constants_pkg.g_regular_run)
    return infa_global%rowtype;

    function get_process_ranges_parm_row(p_process_name in process_ranges_parm.process_name%type, p_run_number in process_ranges_parm.run_number%type)
    return process_ranges_parm%rowtype;

    function get_salary_data_stg1(p_case_num salary_data_stg.case_num%type)
    return salary_data_stg%rowtype;
    
    procedure remove_salary_data_stg1(p_case_num salary_data_stg.case_num%type);

    PROCEDURE update_partition_table_parm_1(p_row partition_table_parm%rowtype);
    PROCEDURE update_partition_table_parm_2(p_table_owner partition_table_parm.table_owner%TYPE,
                                            p_table_name  partition_table_parm.table_name%TYPE,
                                            p_row partition_table_parm%rowtype);
                                            
    procedure reset_partition_parm;

end crud_pkg;
