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


    procedure archive_rules_preanalysis(p_number_of_runs in archive_rules.job_nbr%type, p_partitioned_flag in partition_table_parm.partitioned%type)
    is
        type parm_table_update_t is table of archive_rules%rowtype index by pls_integer;
        src_tables_update parm_table_update_t;
        arch_tables_update parm_table_update_t;

        cursor cur_dataToArchive is --find a way to consider both the partition parm table AND the archive rules table (to ensure both tables agree)
        select rownum as rwnum
        , mod(rownum -1, p_number_of_runs) + 1  as job_nbr
        --, v.num_rows
        , archive.*
        , nvl(part.partitioned, partition_parm_pkg.g_is_not_partitioned) as partitioned
        , partition_type
        , partition_prefix
        from base_archive_table_match archive
        
        left outer join partition_table_parm part
        on archive.base_table_name = part.table_name
        
        /*inner join all_tables v
        on v.owner = archive.base_table_owner
        and v.table_name = archive.base_table_name
        order by job_nbr, v.num_rows asc*/
        ;

        procedure updateJobNbrs(p_collection in parm_table_update_t)
        is
        begin

            forall i in indices of p_collection            
            update archive_rules
            set job_nbr = p_collection(i).job_nbr
            where table_owner = p_collection(i).table_owner
            and table_name = p_collection(i).table_name;

        end updateJobNbrs;

    begin
        assert_pkg.is_true(p_partitioned_flag in (partition_parm_pkg.g_is_partitioned, partition_parm_pkg.g_is_not_partitioned), 'INVALID FLAG PASSED. PLEASE CORRECT');
        
        sql_utils_pkg.toggle_trigger('arch_rules_pf_check_trg', p_turn_on => false);
        
        archive_rules_tapi.reset_archive_rules;

        sql_utils_pkg.commit;

        for rec_archive in cur_dataToArchive
        loop
            src_tables_update(rec_archive.rwnum).table_owner := rec_archive.base_table_owner;
            src_tables_update(rec_archive.rwnum).table_name  := rec_archive.base_table_name;
            src_tables_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;

            arch_tables_update(rec_archive.rwnum).table_owner := rec_archive.archive_table_owner;
            arch_tables_update(rec_archive.rwnum).table_name  := rec_archive.archive_table_name;
            arch_tables_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;
        end loop;

        updateJobNbrs(src_tables_update);
        updateJobNbrs(arch_tables_update);
        sql_utils_pkg.commit;

    END archive_rules_preanalysis;
    
    
    function gen_pin_preanalysis(p_process_name in process_ranges_parm.PROCESS_NAME%type, p_values in t_str_array, p_number_of_runs in process_ranges_parm.RUN_TOTAL%type)
    return process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab
    is
        l_returnvalue process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab := process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab();
        
        cursor gen_cursor is
           with dta as (
               select * from (
                   select g_min_pin as value from dual
                   
                   union all
                   
                   select distinct COLUMN_VALUE as value
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
        , split as (
            select job_nbr
            , count(*) as run_total
            , min(value) lower_bound
            , max(value) upper_bound
            from preanalysis
            group by job_nbr
        )
        
        select distinct p_process_name as process_name
        , split.*
        from split;
    begin
       for rec in gen_cursor
       loop
           l_returnvalue.EXTEND;
           l_returnvalue(l_returnvalue.COUNT).PROCESS_NAME := rec.process_name;
           l_returnvalue(l_returnvalue.COUNT).RUN_NUMBER   := rec.job_nbr;
           l_returnvalue(l_returnvalue.COUNT).RUN_TOTAL    := rec.run_total;
           l_returnvalue(l_returnvalue.COUNT).LOWER_BOUND  := rec.lower_bound;
           l_returnvalue(l_returnvalue.COUNT).UPPER_BOUND  := rec.upper_bound;
       end loop;
       
       return l_returnvalue;
    
    exception
        when others then
        raise;
    end gen_pin_preanalysis;
    
    procedure salary_processing_preanalysis(p_number_of_runs in process_ranges_parm.RUN_TOTAL%type)
    is
        cursor cur_salary_pins is
        select --distinct
        pin as pin
        from temp_pins;
        
        l_table t_str_array := t_str_array();
        l_parm_table process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab := process_ranges_parm_tapi.PROCESS_RANGES_PARM_tapi_tab();
    begin
        process_ranges_parm_tapi.del(process_preanalysis_pkg.get_constant_process_salary);
        sql_utils_pkg.commit;    
    
       for rec in cur_salary_pins
       loop
           l_table.EXTEND;
           l_table(l_table.COUNT) := rec.pin;
       end loop;
       
       l_parm_table := gen_pin_preanalysis(p_process_name => process_preanalysis_pkg.get_constant_process_salary
                                         , p_values => l_table
                                         , p_number_of_runs => p_number_of_runs);
        
       for rec in l_parm_table.first..l_parm_table.last
       loop
            process_ranges_parm_tapi.ins(
             p_PROCESS_NAME => l_parm_table(rec).process_name
            ,p_RUN_TOTAL    => l_parm_table(rec).run_total
            ,p_RUN_NUMBER   => l_parm_table(rec).run_number
            ,p_LOWER_BOUND  => l_parm_table(rec).lower_bound
            ,p_UPPER_BOUND  => l_parm_table(rec).upper_bound
            );
       end loop;
       
       check_for_overlap(p_process_name => process_preanalysis_pkg.get_constant_process_salary);
       
       sql_utils_pkg.commit;
                                     
    exception
        when others then
        cleanup_pkg.exception_cleanup(p_rollback => true);
        raise;
    end salary_processing_preanalysis;
    
    
    
    
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
