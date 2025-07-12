create or replace package archive_rules_tbl_pkg
as
    g_archive_table_prefix CONSTANT VARCHAR2(5) := 'ARCH_';
    
    type ref_cursor_t is ref cursor;

    procedure reset_archive_parm_table;
    
    procedure run_archival(p_job_nbr IN archive_rules.job_nbr%type, p_partition_flag IN archive_rules.partitioned%type);

    /*procedure remove_from_archive_rules(p_table_owner        IN archive_rules.table_owner%type
                                      , p_table_name         IN archive_rules.table_name%type);*/

    PROCEDURE partitioned_append_to_archive(p_src_owner          IN partition_table_parm.TABLE_OWNER%TYPE
                                          , p_src_table          IN partition_table_parm.TABLE_NAME%TYPE
                                          , p_src_partition_name IN ALL_TAB_PARTITIONS.PARTITION_NAME%TYPE 
                                          , p_arch_owner         IN partition_table_parm.TABLE_OWNER%TYPE
                                          , p_arch_table         IN partition_table_parm.TABLE_NAME%TYPE
                                          , p_column_name        IN ARCHIVE_RULES.ARCHIVE_COLUMN_KEY%TYPE);

    procedure unpartitioned_append_to_archive(p_src_owner        in archive_rules.table_owner%type
                                            , p_src_table        in archive_rules.table_name%type
                                            , p_arch_owner       in archive_rules.table_owner%type
                                            , p_arch_table       in archive_rules.table_name%type
                                            , p_time_column       in archive_rules.archive_column_key%type
                                            , p_group_column       in archive_rules.archive_column_key%type);



    procedure partitioned_collect_to_archive(p_src_owner         in archive_rules.table_owner%type
                                          , p_src_table          in archive_rules.table_name%type
                                          , p_src_partition_name in all_tab_partitions.partition_name%type 
                                          , p_arch_owner         in archive_rules.table_owner%type
                                          , p_arch_table         in archive_rules.table_name%type
                                          , p_bulk_limit         in integer default 250000);

    procedure unpartitioned_collect_to_archive(p_src_owner       in archive_rules.table_owner%type
                                            , p_src_table        in archive_rules.table_name%type
                                            , p_arch_owner       in archive_rules.table_owner%type
                                            , p_arch_table       in archive_rules.table_name%type
                                            , p_bulk_limit       in integer default 250000);

end archive_rules_tbl_pkg;
