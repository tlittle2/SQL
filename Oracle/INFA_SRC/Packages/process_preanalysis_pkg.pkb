create or replace package body process_preanalysis_pkg
as

    function get_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic
    is
    begin
        return c_process_salaries;
    end get_constant_process_salary;


    procedure archive_rules_preanalysis(p_number_of_runs in number, p_partitioned_flag in partition_table_parm.partitioned%type)
    is
        type parm_table_update_t is table of archive_rules%rowtype index by pls_integer;
        src_tables_update parm_table_update_t;
        arch_tables_update parm_table_update_t;

        cursor cur_dataToArchive is --find a way to consider both the partition parm table AND the archive rules table (to ensure both tables agree)
              select rownum                         as rwnum
            , mod(rownum -1, p_number_of_runs) + 1  as job_nbr
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
            --and parm_src.table_name = substr(parm_arch.table_name, length(archive_rules_tbl_pkg.g_archive_table_prefix)+1,length(parm_arch.table_name))
            and parm_src.table_name = archive_rules_tbl_pkg.get_base_tab_name_from_archive(parm_arch.table_name)
            and parm_src.partitioned = parm_arch.partitioned

            where parm_src.partitioned = p_partitioned_flag
            order by job_nbr, tbl_volume asc;

        procedure updateJobNbrs(p_collection in parm_table_update_t)
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
        assert_pkg.is_true(p_partitioned_flag in (partition_parm_pkg.g_is_partitioned, partition_parm_pkg.g_is_not_partitioned), 'INVALID FLAG PASSED. PLEASE CORRECT');

        sql_utils_pkg.toggle_trigger('arch_rules_pf_check_trg', p_turn_on => false);

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

end process_preanalysis_pkg;
