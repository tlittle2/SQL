create or replace package body crud_pkg
as
    function get_infa_global_row
    return infa_global%rowtype
    is
        l_returnvalue infa_global%rowtype;
    begin
        select *
        into l_returnvalue
        from infa_global;

        return l_returnvalue;
        
    exception
        when others then
        raise;

    end get_infa_global_row;

	function get_global_fix_row
    return infa_global%rowtype
    is
        l_returnvalue infa_global%rowtype;
    begin
        select *
        into l_returnvalue
        from infa_global_fix;

        return l_returnvalue;
    exception
        when others then
        raise;
    end get_global_fix_row;

    function get_global_row_logic(p_run_type IN CHAR := global_constants_pkg.g_regular_run)
    return infa_global%rowtype
    is
    l_returnvalue infa_global%rowtype;
    begin
        assert_pkg.is_valid_run_mode(p_run_type, 'INVALID RUN TYPE PROVIDED. PLEASE CORRECT');
        if p_run_type = global_constants_pkg.g_special_run
		then
		    l_returnvalue:= get_global_fix_row;
		else
            l_returnvalue:= get_infa_global_row;
		end if;

        return l_returnvalue;
        
    exception
        when others then
        raise;

    end get_global_row_logic;


    function get_process_ranges_parm_row(p_process_name in process_ranges_parm.process_name%type, p_run_number in process_ranges_parm.run_number%type)
    return process_ranges_parm%rowtype
    is
        l_returnvalue process_ranges_parm%rowtype;
    begin
        assert_pkg.is_true(
            p_process_name in (
                process_preanalysis_pkg.c_process_salaries
                ), 'CONSTANT NOT RECOGNIZED! PLEASE INVESTIGATE!'
        );

        select * into l_returnvalue from process_ranges_parm
        where process_name = p_process_name
        and run_number = p_run_number;

        assert_pkg.is_true(l_returnvalue.lower_bound is not null and l_returnvalue.upper_bound is not null, 'INVALID RANGE FOUND FOR PARAMETERS PROVIDED! PLEASE INVESTIGATE!');

        return l_returnvalue;

    exception
        --TODO: do something more creative here
        when others then
            raise;
    end get_process_ranges_parm_row;


    function get_salary_data_stg1(p_case_num salary_data_stg.case_num%type)
    return salary_data_stg%rowtype
    is
    l_return_value salary_data_stg%rowtype;
    begin
        select *
        into l_return_value
        from salary_data_stg
        where case_num = p_case_num;

        return l_return_value;

    exception
       --TODO: do something more creative here
       when no_data_found then
           raise;
        when others then
           raise;

    end get_salary_data_stg1;
    
    procedure remove_salary_data_stg1(p_case_num salary_data_stg.case_num%type)
    is
    begin
        delete
        from salary_data_stg
        where case_num = p_case_num;
    exception
        when no_data_found then
        raise;
        
        when others then
        raise;
    end remove_salary_data_stg1;


    PROCEDURE update_partition_table_parm_1(p_row partition_table_parm%rowtype)
    is
    begin
        update partition_table_parm set row = p_row;
    exception
        when others then
        raise;
    end update_partition_table_parm_1;


    PROCEDURE update_partition_table_parm_2(p_table_owner partition_table_parm.table_owner%TYPE,
                                            p_table_name  partition_table_parm.table_name%TYPE,
                                            p_row partition_table_parm%rowtype)
    is
    begin
        assert_pkg.is_not_null(p_table_owner, 'Table Owner is Null. Please investigate');
        assert_pkg.is_not_null(p_table_name, 'Table Owner is Null. Please investigate');
        
        update partition_table_parm set row = p_row
        where table_owner = p_table_owner
        and table_name = p_table_name;
    
    exception
        when others then
        raise;
    end update_partition_table_parm_2;
    
    
    procedure reset_partition_parm
    is
    begin
        update partition_table_parm
        set upd_flag = global_constants_pkg.g_record_is_not_updated;
        commit;
    exception
        when no_data_found then
        raise;
        when others then
        raise;
    end reset_partition_parm;


end crud_pkg;
