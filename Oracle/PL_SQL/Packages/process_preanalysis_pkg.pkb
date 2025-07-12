create or replace package body process_preanalysis_pkg
as

    function retrieve_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic
    is
    begin
        return c_process_salaries;
    end retrieve_constant_process_salary;
    
    
    procedure retrieve_range_values(p_process_name in process_ranges_parm.process_name%type, p_run_number in process_ranges_parm.run_number%type, p_parms out range_parm_values_t)
    is
    begin
        error_pkg.assert(p_process_name in (c_process_salaries), 'CONSTANT NOT RECOGNIZED! PLEASE INVESTIGATE!');

        select lower_bound, upper_bound
        into p_parms.lower_bound, p_parms.upper_bound
        from process_ranges_parm
        where process_name = p_process_name
        and run_number = p_run_number;
        
        dbms_output.put_line(string_utils_pkg.get_str('lower bound: %1', p_parms.lower_bound));
        dbms_output.put_line(string_utils_pkg.get_str('upper bound: %1',p_parms.upper_bound));
        
        --dbms_output.put_line('lower bound: ' || p_parms.lower_bound);
        --dbms_output.put_line('upper bound: ' || p_parms.upper_bound);
        
        error_pkg.assert(p_parms.lower_bound is not null and p_parms.upper_bound is not null, 'NO RANGE FOUND FOR PARAMETERS PROVIDED! PLEASE INVESTIGATE!');
        
        
    exception
        when others then
        error_pkg.print_error('retrieve_range_values');
        raise;

    end retrieve_range_values;
    
    procedure archive_rules_preanalysis(p_number_of_runs in NUMBER, p_partitioned_flag IN partition_table_parm.partitioned%type)
    is
        TYPE jobParm_t is RECORD(
        table_owner archive_rules.table_owner%type,
        table_name  archive_rules.table_name%type,
        job_nbr     archive_rules.job_nbr%type);
        
        type parm_table_update_t is table of jobParm_t index by pls_integer;
        
        cursor cur_dataToArchive is --find a way to consider both the partition parm table AND the archive rules table (to ensure both tables agree)
              SELECT ROWNUM                         as rwnum
            , MOD(ROWNUM -1, p_number_of_runs) + 1  as job_nbr
            , v.num_rows                            as tbl_volume
            , parm_src.table_owner                  as src_table_owner
            , parm_src.table_name                   as src_table_name
            , parm_arch.table_owner                 as arch_table_owner
            , parm_arch.table_name                  as arch_table_name
            from all_tables v
            
            inner join archive_rules parm_src
            on v.owner = parm_src.table_owner
            and v.table_name = parm_src.table_name
            inner join archive_rules parm_arch
            on parm_src.table_owner = parm_arch.table_owner
            and parm_src.table_name = substr(parm_arch.table_name, length(archive_rules_tbl_pkg.g_archive_table_prefix)+1,length(parm_arch.table_name))
            and parm_src.partitioned = parm_arch.partitioned
            
            where parm_src.partitioned = p_partitioned_flag
            order by job_nbr, tbl_volume asc;
            
            src_tables_update parm_table_update_t;
            arch_tables_update parm_table_update_t;
        
        procedure updateJobNbrs(p_collection IN parm_table_update_t)
        is
        begin
            
            forall i in indices of p_collection
            update archive_rules
            set job_nbr = p_collection(i).job_nbr
            where table_owner = p_collection(i).table_owner
            and table_name = p_collection(i).table_name
            and partitioned = p_partitioned_flag;
            
        end updateJobNbrs;
        
    begin
        error_pkg.assert(p_partitioned_flag in (PARTITION_PARM_PKG.g_is_partitioned, PARTITION_PARM_PKG.g_is_not_partitioned), 'INVALID FLAG PASSED TO THIS FUNCTION. PLEASE CORRECT');
    
        update archive_rules
        set job_nbr = null
        where partitioned = p_partitioned_flag;
        commit;
        
        for rec_archive in cur_dataToArchive
        loop
            src_tables_update(rec_archive.rwnum).table_owner := rec_archive.src_table_owner;
            src_tables_update(rec_archive.rwnum).table_name  := rec_archive.src_table_name;
            src_tables_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;
            
            arch_tables_update(rec_archive.rwnum).table_owner := rec_archive.arch_table_owner;
            arch_tables_update(rec_archive.rwnum).table_name  := rec_archive.arch_table_name;
            arch_tables_update(rec_archive.rwnum).job_nbr     := rec_archive.job_nbr;
        
        end loop;
        
        updateJobNbrs(src_tables_update);
        updateJobNbrs(arch_tables_update);
        
        commit;

    END archive_rules_preanalysis;
    
    
    
---======================================================================================================================================================================================================
    
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
    
end process_preanalysis_pkg;
