create or replace package archive_rules_tbl_pkg
as
/*Archival/Purge Rules (should determine preanalysis and drivers)
    --Archival
        --Any base table that has a corresponding archive table in archive_rules = data will move from the base table to the archive table through automation
        --Any base table that DOES NOT has a corresponding archive table in archive_rules= NO ACTION

    --Purge
        --Any base table that has a corresponding archive table in archive_rules = data will get purged from the archive table
        --Any base table that DOES NOT has a corresponding archive table in archive_rules= data will get purged from the base table
*/

    g_archive_table_prefix CONSTANT CHAR(5) := 'ARCH_';

    c_bulk_limit constant number(6,0) := 250000;

    function get_archive_table_prefix
    return varchar2 deterministic;

    function get_base_tab_name_from_archive(p_table_name in varchar2)
    return varchar2;

    function get_arch_prefix_from_tab(p_table_name in varchar2)
    return varchar2;

    function get_arch_table(p_table_name in archive_rules.table_name%type)
    return archive_rules%rowtype;

--=================================================job number drivers==================================================================================

    PROCEDURE run_purge(p_run_mode IN global_constants_pkg.g_regular_run%type, p_job_nbr IN archive_rules.JOB_NBR%type);

    PROCEDURE run_archival(p_move_run_mode IN global_constants_pkg.g_regular_run%type, p_job_nbr IN archive_rules.JOB_NBR%type);

--=================================================partitioned drivers=================================================================================

    procedure run_partitioned_archival(p_BASE_TABLE_OWNER    in archive_rules.table_owner%type,
                                       p_BASE_TABLE_NAME     in archive_rules.table_name%type,
                                       p_ARCHIVE_TABLE_OWNER in archive_rules.table_owner%type,
                                       p_ARCHIVE_TABLE_NAME  in archive_rules.table_name%type,
                                       p_cutoff_dte          in date,
                                       p_ARCHIVE_GROUP_KEY   in archive_rules.archive_group_key%type,
                                       p_PARTITION_TYPE      in partition_table_parm.partition_type%type,
                                       p_PARTITION_PREFIX    in partition_table_parm.partition_prefix%type);

    PROCEDURE partitioned_append_to_archive(p_src_owner          IN archive_rules.TABLE_OWNER%TYPE
                                          , p_src_table          IN archive_rules.TABLE_NAME%TYPE
                                          , p_src_partition_name IN ALL_TAB_PARTITIONS.PARTITION_NAME%TYPE
                                          , p_arch_owner         IN archive_rules.TABLE_OWNER%TYPE
                                          , p_arch_table         IN archive_rules.TABLE_NAME%TYPE
                                          , p_group_column       IN ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%TYPE);


    procedure partitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                          , p_src_table          in archive_rules.table_name%type
                                          , p_src_partition_name in all_tab_partitions.partition_name%type
                                          , p_arch_owner         in archive_rules.table_owner%type
                                          , p_arch_table         in archive_rules.table_name%type
                                          , p_bulk_limit         in integer default c_bulk_limit);


--==============================================nonpartitioned drivers=================================================================================



    procedure run_nonpartitioned_archival(p_BASE_TABLE_OWNER    in archive_rules.table_owner%type,
                                          p_BASE_TABLE_NAME     in archive_rules.table_name%type,
                                          p_ARCHIVE_TABLE_OWNER in archive_rules.table_owner%type,
                                          p_ARCHIVE_TABLE_NAME  in archive_rules.table_name%type,
                                          p_YEARS_TO_KEEP       in archive_rules.years_to_keep%type,
                                          p_ARCHIVE_COLUMN_KEY  in archive_rules.archive_column_key%type,
                                          p_ARCHIVE_GROUP_KEY   in archive_rules.archive_group_key%type);


    procedure unpartitioned_append_to_archive(p_src_owner          in archive_rules.table_owner%type
                                            , p_src_table          in archive_rules.table_name%type
                                            , p_arch_owner         in archive_rules.table_owner%type
                                            , p_arch_table         in archive_rules.table_name%type
                                            , p_ARCHIVE_COLUMN_KEY in archive_rules.archive_column_key%type
                                            , p_ARCHIVE_GROUP_KEY  in archive_rules.archive_group_key%type);


    procedure unpartitioned_collect_to_archive(p_src_owner       in archive_rules.table_owner%type
                                            , p_src_table        in archive_rules.table_name%type
                                            , p_arch_owner       in archive_rules.table_owner%type
                                            , p_arch_table       in archive_rules.table_name%type
                                            , p_bulk_limit       in integer default c_bulk_limit);

end archive_rules_tbl_pkg;
