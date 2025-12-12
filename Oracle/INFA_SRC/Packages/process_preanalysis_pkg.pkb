create or replace package body process_preanalysis_pkg
as

    function get_constant_process_salary
    return process_ranges_parm.process_name%type
    deterministic
    is
    begin
        return c_process_salaries;
    end get_constant_process_salary;

    function generate_job_nbrs(p_current_value in integer, p_high_value in integer, p_job_runs in integer)
    return integer
    is
    begin
        return mod(floor(p_current_value / round(p_high_value/p_job_runs, 0)), p_job_runs) + 1;
    end;



    procedure archive_rules_preanalysis(p_number_of_runs in number, p_partitioned_flag in partition_table_parm.partitioned%type)
    is
        type parm_table_update_t is table of archive_rules%rowtype index by pls_integer;
        src_tables_update parm_table_update_t;
        arch_tables_update parm_table_update_t;

        cursor cur_dataToArchive is --find a way to consider both the partition parm table AND the archive rules table (to ensure both tables agree)
        with src_archive as (
           select TABLE_OWNER as src_table_owner, TABLE_NAME as src_table_name, YEARS_TO_KEEP as src_years_to_keep, ARCHIVE_COLUMN_KEY as src_archive_column, ARCHIVE_GROUP_KEY as src_group_by
           from archive_rules
           where archive_rules_tbl_pkg.get_arch_prefix_from_tab(TABLE_NAME) <> archive_rules_tbl_pkg.g_archive_table_prefix
        )

        , arch_archive as (
           select TABLE_OWNER as arch_table_owner, TABLE_NAME as arch_table_name
           from archive_rules
           where archive_rules_tbl_pkg.get_arch_prefix_from_tab(TABLE_NAME) = archive_rules_tbl_pkg.g_archive_table_prefix
        )

        , joined_archive as (
        select * from src_archive src
        inner join arch_archive arch
        on src.src_table_owner = arch.arch_table_owner
        and src.src_table_name = archive_rules_tbl_pkg.get_base_tab_name_from_archive(arch.arch_table_name)
        )

        , partition_parms as (
            select table_owner as part_owner, table_name as part_table, partitioned as partitioned, partition_type, partition_prefix
            from partition_table_parm
            where archive_rules_tbl_pkg.get_arch_prefix_from_tab(TABLE_NAME) <> archive_rules_tbl_pkg.g_archive_table_prefix
        )

        select rownum as rwnum
        , mod(rownum -1, p_number_of_runs) + 1  as job_nbr
        , v.num_rows
        , archive.*
        , nvl(part.partitioned, partition_parm_pkg.g_is_not_partitioned) as partitioned
        from joined_archive archive
        left outer join partition_parms part
        on archive.src_table_name = part.part_table

        inner join all_tables v
        on v.owner = archive.src_table_owner
        and v.table_name = archive.src_table_name
        order by job_nbr, v.num_rows asc;

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

        update archive_rules
        set job_nbr = null;

        sql_utils_pkg.commit;

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
        sql_utils_pkg.commit;

    END archive_rules_preanalysis;

end process_preanalysis_pkg;
