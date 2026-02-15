create or replace package body process_preanalysis_pkg
as
    
    subtype st_pin_len is varchar2(12);
    
    g_min_pin st_pin_len := '0000000';
    g_max_pin st_pin_len := '999999999999';
    

    function get_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic
    is
    begin
        return c_process_salaries;
    end get_constant_process_salary;
    
    function get_constant_contract_update
    return process_ranges_parm.process_name%type
    deterministic
    is
    begin
        return c_contract_update;
    end get_constant_contract_update;


    function generate_job_nbrs(p_current_value in process_ranges_parm.RUN_TOTAL%type, p_count_of_values in process_ranges_parm.RUN_TOTAL%type, p_job_runs in process_ranges_parm.RUN_TOTAL%type)
    return integer
    is
    begin
        return trunc((p_current_value -1) / get_count_per_run(p_count_of_values,p_job_runs)) + 1;
    end generate_job_nbrs;
    
    
    function get_count_per_run(p_number_of_values in process_ranges_parm.RUN_TOTAL%type, p_job_runs in process_ranges_parm.RUN_TOTAL%type)
    return integer
    is
    begin
        return ceil(p_number_of_values / p_job_runs);
    end get_count_per_run;
    
    
    function gen_pin_preanalysis(p_process_name in process_ranges_parm.PROCESS_NAME%type, p_values in t_str_array, p_number_of_runs in process_ranges_parm.RUN_TOTAL%type)
    return process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab
    is
        l_returnvalue process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab := process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab();
    begin
           with dta as (
               select * from (
                   select g_min_pin as value from dual
                   
                   union all
                   
                   select distinct COLUMN_VALUE as value --good practice to distinct from caller function for higher volumes, but just in case
                   from table(p_values)
                   
                   union all
                   
                   select g_max_pin as value from dual
                ) order by value asc
            )
        , counts as (
            select count(distinct value) as cnt
            from dta
        )
        , preanalysis as (
            select dta.value
            , counts.cnt
            , process_preanalysis_pkg.generate_job_nbrs(row_number() over(order by value asc), cnt, p_number_of_runs) as job_nbr
            from dta, counts
        )
         select p_process_name, job_nbr
            , count(*) as run_total
            , min(value) lower_bound
            , max(value) upper_bound
            bulk collect into l_returnvalue
            from preanalysis
            group by job_nbr;
       
       return l_returnvalue;
    
    exception
        when others then
        error_pkg.print_error('gen_pin_preanalysis');
        raise;
    end gen_pin_preanalysis;
    
    
    procedure update_preanalysis_table(p_values in process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab)
    is
    begin
       for rec in p_values.first..p_values.last
       loop
            process_ranges_parm_tapi.ins(
             p_PROCESS_NAME => p_values(rec).process_name
            ,p_RUN_TOTAL    => p_values(rec).run_total
            ,p_RUN_NUMBER   => p_values(rec).run_number
            ,p_LOWER_BOUND  => p_values(rec).lower_bound
            ,p_UPPER_BOUND  => p_values(rec).upper_bound
            );
       end loop;
    exception
        when others then
        raise;
    end update_preanalysis_table;
    
    procedure reset_process(p_process_name in process_ranges_parm.PROCESS_NAME%type, p_parm_table in process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab)
    is
        l_process_name process_ranges_parm.process_name%type;
    begin
       select distinct process_name into l_process_name from table(p_parm_table);
       
       assert_pkg.is_true(p_process_name = l_process_name, 'POTENTIALLY UNSAFE DELETE. PLEASE INVESTIGATE');
       process_ranges_parm_tapi.del(l_process_name); 
       process_ranges_parm_tapi.ins_bulk(p_parm_table);
       sql_utils_pkg.commit;
       
    exception
        when too_many_rows then
        assert_pkg.is_true('DEVELOPER' = 'DUMBASS', 'ONE PROCESS AT A TIME YALL. PLEASE INVESTIGATE');

        when others then
        raise;
    end reset_process;
    
    function select_values_for_preanalysis(p_process_name in process_ranges_parm.PROCESS_NAME%type)
    return t_str_array
    is
        l_table t_str_array;
    begin
        assert_pkg.is_true(p_process_name in(process_preanalysis_pkg.c_contract_update, process_preanalysis_pkg.get_constant_process_salary) , 'POTENTIALLY UNSAFE DELETE. PLEASE INVESTIGATE');
        
        if p_process_name = process_preanalysis_pkg.c_contract_update
        then
            select distinct contract as contract
            bulk collect into l_table
            from temp_contracts;
        
        elsif p_process_name = process_preanalysis_pkg.get_constant_process_salary
        then
            select distinct pin as pin
            bulk collect into l_table
            from temp_pins;
        end if;
        
        return l_table;
        
    exception
        when others then
        error_pkg.print_error('select_values_for_preanalysis');
        raise;
    end select_values_for_preanalysis;
    
    procedure salary_processing_preanalysis(p_number_of_runs in process_ranges_parm.RUN_TOTAL%type)
    is
        l_table t_str_array := t_str_array();
        l_parm_table process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab := process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab();
    begin
        l_table := select_values_for_preanalysis(process_preanalysis_pkg.get_constant_process_salary);
       
        l_parm_table := gen_pin_preanalysis(p_process_name   => process_preanalysis_pkg.get_constant_process_salary
                                          , p_values         => l_table
                                          , p_number_of_runs => p_number_of_runs);
       
       reset_process(process_preanalysis_pkg.get_constant_process_salary, l_parm_table);
    exception
        when others then
        cleanup_pkg.exception_cleanup(p_rollback => true);
        raise;
    end salary_processing_preanalysis;
    
    
    procedure update_contract_preanalysis(p_number_of_runs in process_ranges_parm.RUN_TOTAL%type)
    is
        l_table t_str_array := t_str_array();
        l_parm_table process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab := process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab();
    begin
        l_table := select_values_for_preanalysis(process_preanalysis_pkg.c_contract_update);
       
       l_parm_table := gen_pin_preanalysis(p_process_name   => process_preanalysis_pkg.c_contract_update
                                         , p_values         => l_table
                                         , p_number_of_runs => p_number_of_runs);
                                         
       reset_process(process_preanalysis_pkg.c_contract_update, l_parm_table);
    exception
        when others then
        cleanup_pkg.exception_cleanup(p_rollback => true);
        error_pkg.print_error('update_contract_preanalysis');
        raise;
    end update_contract_preanalysis;
    
    function archive_rules_jobNumber(p_rownum in number, p_num_of_runs in archive_rules.job_nbr%type)
    return archive_rules.job_nbr%type
    is
        l_returnvalue archive_rules.job_nbr%type := mod(p_rownum -1, p_num_of_runs) + 1;
    begin
        
        return l_returnvalue;
    
    end archive_rules_jobNumber;
    
    procedure update_archive_rules(p_collection in archive_rules_tapi.archive_rules_update_tapi_tab)
    is
    begin
        forall i in indices of p_collection            
        update archive_rules
        set job_nbr = p_collection(i).job_nbr
        where table_owner = p_collection(i).table_owner
        and table_name = p_collection(i).table_name;
    exception
        when others then
            cleanup_pkg.exception_cleanup(p_rollback => true);
            error_pkg.print_error('update_archive_rules');
            raise;
    end update_archive_rules;
    
    procedure archive_preanalysis(p_number_of_runs in archive_rules.job_nbr%type)
    is
        l_src_parm_update archive_rules_tapi.archive_rules_update_tapi_tab;
        l_arch_parm_update archive_rules_tapi.archive_rules_update_tapi_tab;

        cursor cur_dataToArchive is
        select rownum as rwnum
        , process_preanalysis_pkg.archive_rules_jobNumber(rownum, p_number_of_runs) as job_nbr
        , v.num_rows
        , archive.*
        , nvl(part.partitioned, partition_parm_pkg.g_is_not_partitioned) as partitioned
        from base_archive_table_match archive
        left outer join partition_table_parm part
        on archive.base_table_name = part.table_name
        
        inner join all_tables v
        on v.owner = archive.base_table_owner
        and v.table_name = archive.base_table_name
        
        where archive_table_name is not null
        order by job_nbr asc, v.num_rows desc;

    begin
        sql_utils_pkg.toggle_trigger('arch_rules_pf_check_trg', p_turn_on => false);
        
        archive_rules_tapi.reset_archive_rules;

        for rec_archive in cur_dataToArchive
        loop
            l_src_parm_update(rec_archive.rwnum).table_owner := rec_archive.base_table_owner;
            l_src_parm_update(rec_archive.rwnum).table_name  := rec_archive.base_table_name;
            l_src_parm_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;
            
            l_arch_parm_update(rec_archive.rwnum).table_owner := rec_archive.ARCHIVE_TABLE_OWNER;
            l_arch_parm_update(rec_archive.rwnum).table_name  := rec_archive.ARCHIVE_TABLE_NAME;
            l_arch_parm_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;

        end loop;

        update_archive_rules(l_src_parm_update);
        update_archive_rules(l_arch_parm_update);
        sql_utils_pkg.commit;
        
    exception
        when others then
            error_pkg.print_error('archive_preanalysis');
            raise;
    END archive_preanalysis;
    
    
    procedure purge_preanalysis(p_number_of_runs in archive_rules.job_nbr%type)
    is
        l_arch_parm_update archive_rules_tapi.archive_rules_update_tapi_tab;
        l_src_parm_update archive_rules_tapi.archive_rules_update_tapi_tab;
        
        cursor archiveToPurge is
        with ds as (
        select v.num_rows
        , archive.*
        from
        base_archive_table_match archive
        left outer join partition_table_parm part
        on archive.base_table_name = part.table_name
        
        inner join all_tables v
        on v.owner = archive.base_table_owner
        and v.table_name = archive.base_table_name
        )
        select * from (
        select rownum as rwnum
        , process_preanalysis_pkg.archive_rules_jobNumber(rownum, p_number_of_runs) as job_nbr
        , ds.*
        from ds
        where archive_table_owner is not null
        
        union all
        
        select rownum as rwnum
        , -process_preanalysis_pkg.archive_rules_jobNumber(rownum, p_number_of_runs) as job_nbr
        , ds.*
        from ds
        where archive_table_owner is null
        ) order by job_nbr asc, num_rows desc;
    
    begin
        archive_rules_tapi.reset_archive_rules;
        
        for rec_archive in archiveToPurge
        loop
            l_src_parm_update(rec_archive.rwnum).table_owner := coalesce(rec_archive.archive_table_owner, rec_archive.base_table_owner);
            l_src_parm_update(rec_archive.rwnum).table_name  := coalesce(rec_archive.archive_table_name, rec_archive.base_table_name);
            l_src_parm_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;

            update_archive_rules(l_src_parm_update);
            
        end loop;
        
        sql_utils_pkg.commit;
        
        update_archive_rules(l_src_parm_update);
        update_archive_rules(l_arch_parm_update);
        sql_utils_pkg.commit;
        
    exception
        when others then
            error_pkg.print_error('purge_preanalysis');
            raise;
    end purge_preanalysis;
    
    
    
    procedure check_for_overlap(p_process_name in process_ranges_parm.process_name%type)
    is
        l_count number;
    begin
        select nvl(count(*), 0)
        into l_count
        from process_ranges_parm d1, process_ranges_parm d2
        where 
        d1.process_name = d2.process_name
        and d1.process_name = p_process_name
        and 
        (
            ((d1.lower_bound between d2.lower_bound and d2.upper_bound and d1.run_number <> d2.run_number) or (d1.upper_bound between d2.lower_bound and d2.upper_bound and d1.run_number <> d2.run_number))
            or 
            ((d2.lower_bound between d1.lower_bound and d1.upper_bound and d2.run_number <> d1.run_number) or (d2.upper_bound between d1.lower_bound and d2.upper_bound and d2.run_number <> d1.run_number))
        );
        
        assert_pkg.is_equal_to_zero(l_count, string_utils_pkg.get_str('THERE MAY BE OVERLAP IN PREANALYSIS SPLIT FOR - %1 -. PLEASE INVESTIGATE', p_process_name));
        
    exception
        when others then
        raise;
    end check_for_overlap;

end process_preanalysis_pkg;
